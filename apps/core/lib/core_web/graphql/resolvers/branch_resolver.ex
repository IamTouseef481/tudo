defmodule CoreWeb.GraphQL.Resolvers.BranchResolver do
  @moduledoc false
  use CoreWeb.GraphQL, :resolver
  alias Core.{BSP, Accounts}
  alias CoreWeb.GraphQL.Resolvers.BusinessResolver

  def list_branches_by(_, %{input: input}, %{context: %{current_user: current_user}}) do
    get_branches_list(input, current_user.acl_role_id)
  end

  def list_branches_by(_, _, %{context: %{current_user: current_user}}) do
    get_branches_list(%{}, current_user.acl_role_id)
  end

  defp get_branches_list(input, acl_role_id) do
    if "web" in acl_role_id do
      branches = BSP.list_branches_by(input)

      updated_branches =
        Enum.map(branches.entries, &add_custom_fields_to_branch(&1)) |> sort_branches(input)

      {:ok, Map.merge(branches, %{branches: updated_branches})}
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to list branches"], __ENV__.line)
  end

  defp sort_branches(branches, params) do
    case params do
      %{sort: %{field: "id", ascending: ascending}} ->
        order = if ascending, do: :asc, else: :desc
        Enum.sort_by(branches, & &1.id, order)

      %{sort: %{field: "name", ascending: ascending}} ->
        order = if ascending, do: :asc, else: :desc
        Enum.sort_by(branches, & &1.name, order)

      %{sort: %{field: "employees_count", ascending: ascending}} ->
        order = if ascending, do: :asc, else: :desc
        Enum.sort_by(branches, & &1.employees_count, order)

      %{sort: %{field: "description", ascending: ascending}} ->
        order = if ascending, do: :asc, else: :desc
        Enum.sort_by(branches, & &1.description, order)

      %{sort: %{field: "status_id", ascending: ascending}} ->
        order = if ascending, do: :asc, else: :desc
        Enum.sort_by(branches, & &1.status_id, order)

      _ ->
        Enum.sort_by(branches, & &1.name)
    end
  end

  def get_branch(_, %{input: %{id: id}}, %{context: %{current_user: current_user}}) do
    if "web" in current_user.acl_role_id do
      branch =
        BSP.get_branch!(id)
        |> add_custom_fields_to_branch()

      {:ok, branch}
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  end

  def add_custom_fields_to_branch(branch) do
    branch = %{branch | settings: keys_to_atoms(branch.settings)}

    BusinessResolver.attach_grouped_branch_services_to_branch(branch)
    |> BusinessResolver.add_issuing_authority_name()
    |> BusinessResolver.preload_active_branch_services_to_branch()
    |> CoreWeb.Utils.CommonFunctions.add_geo()
  end

  def create_branch(_, %{input: input}, %{context: %{current_user: current_user}}) do
    country_id =
      case input do
        %{country_id: country_id} -> country_id
        _ -> current_user.country_id
      end

    input =
      Map.merge(input, %{
        country_id: country_id,
        user_id: current_user.id,
        status_id: "admin_confirmation_pending",
        main_branch: false
      })

    case CoreWeb.Controllers.BranchController.create_branch(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["unable to create branch!"]}
    end
  end

  def update_branch(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{updated_by: current_user.id, user_id: current_user.id})

    case CoreWeb.Controllers.BranchController.update_branch(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["unable to update branch!"]}
    end
  end

  def delete_branch(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case CoreWeb.Controllers.BranchController.delete_branch(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def make_branch_active(_, %{input: %{branch_id: branch_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    if "web" in current_user.acl_role_id do
      case BSP.get_branch!(branch_id) do
        nil ->
          {:error, ["branch doesn't exist"]}

        branch ->
          update_branch_to_active(branch, input)
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unexpected error occurred, try again!"], __ENV__.line)
  end

  def update_branch_to_active(branch, input) do
    with {:ok, branch} <- BSP.update_branch(branch, input),
         :ok <- Core.Jobs.DashboardMetaHandler.update_meta_for_employee(branch, ["owner"]) do
      Task.start(fn ->
        create_chat_group_on_branch_active(branch)
        send_email_with_qr_code(branch)
      end)

      {:ok, %{branch | settings: keys_to_atoms(branch.settings)}}
    else
      {:error, changeset} ->
        {:error, changeset}

      _ ->
        {:error, ["unable to update branch!"]}
    end

    # case BSP.update_branch(branch, input) do
    #   {:ok, data} ->
    #     Task.start(fn ->
    #       send_email_with_qr_code(data)
    #     end)

    #     {:ok, %{data | settings: keys_to_atoms(branch.settings)}}

    #   {:error, changeset} ->
    #     {:error, changeset}

    #   _ ->
    #     {:error, ["unable to update branch!"]}
    # end
  end

  def send_email_with_qr_code(%{address: %{"address" => address}} = branch) do
    case Core.BSP.get_business_by_branch_id(branch.id) do
      nil ->
        :ok

      %{user_id: user_id} ->
        %{email: email, profile: %{"first_name" => first_name, "last_name" => last_name}} =
          Accounts.get_user!(user_id)

        attr = %{
          "email" => email,
          "cmr_first_name" => first_name,
          "cmr_last_name" => last_name,
          "bsp_branch_profile_name" => branch.name
        }

        business = %{
          branch_name: branch.name,
          branch_phone: branch.phone,
          branch_address: address,
          profile_pictures: branch.profile_pictures,
          branch_id: branch.id
        }

        CoreWeb.PDF.MakePDF.send_email_with_attachment(
          "bsp_profile_activated",
          attr,
          business
        )
    end
  end

  def create_chat_group_on_branch_active(%{id: branch_id, name: brnach_name}) do
    with %{id: created_by_id} <- Core.Employees.get_owner_user_by_branch_id(branch_id),
         {:ok, _, %{group: group}} <-
           apply(TudoChatWeb.Helpers.GroupHelper, :create_group, [
             %{
               name: brnach_name,
               created_by_id: created_by_id,
               group_type_id: "bus_net",
               group_status_id: "active",
               created_at: DateTime.utc_now(),
               on_branch_active: true,
               branch_id: branch_id
             }
           ]) do
      {:ok, group}
    else
      _ -> {:error, ["Smething went wrong"]}
    end
  end
end
