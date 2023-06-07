defmodule CoreWeb.GraphQL.Resolvers.OrderResolver do
  use CoreWeb, :core_resolver
  alias CoreWeb.Utils.CommonFunctions
  alias CoreWeb.Controllers.OrderController
  alias Core.Orders

  def create_order(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input =
      Map.merge(input, %{
        user: current_user,
        status_id: "pending",
        user_id: current_user.id,
        location_dest: CommonFunctions.location_struct(input[:location_dest])
      })

    with false <- Map.has_key?(input, :location_src),
         {:ok, location_src} <- get_location_src(input) do
      OrderController.create_order(Map.merge(input, %{location_src: location_src}))
    else
      true ->
        location_src = CommonFunctions.location_struct(input[:location_src])
        OrderController.create_order(Map.merge(input, %{location_src: location_src}))

      error ->
        {:error, error}
    end
  end

  def update_order(_, %{input: input}, %{context: %{current_user: current_user}}) do
    case OrderController.update_order(
           Map.merge(input, %{
             user: current_user,
             country_id: current_user.country_id,
             user_id: current_user.id
           })
         ) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  def get_order(_, %{input: input}, %{context: %{current_user: %{id: user_id}}}) do
    case OrderController.get_order(Map.merge(input, %{user_id: user_id})) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  def get_location_src(%{chat_group_id: chat_group_id}) do
    case apply(TudoChat.Groups, :get_group, [chat_group_id]) do
      nil ->
        {:error, ["No group found"]}

      %{branch_id: nil} ->
        {:error, ["Branch does not exist against this group"]}

      %{branch_id: branch_id} ->
        %{location: location} = Core.BSP.get_branch!(branch_id)
        {:ok, location}
    end
  end

  def update_order_status(product_order_id, params) do
    case Orders.get_order(product_order_id) do
      nil ->
        {:error, ["No Order Found"]}

      order ->
        case Orders.update_order(order, params) do
          {:ok, data} ->
            {:ok, data}

          {:error, %Ecto.Changeset{errors: [{k, {msg, _}} | _]}} ->
            {:error, "#{k} " <> "#{msg}"}

          _ ->
            {:error, ["Unable to update order"]}
        end
    end
  end
end
