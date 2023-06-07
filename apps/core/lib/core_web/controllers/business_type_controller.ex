defmodule CoreWeb.Controllers.BusinessTypeController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.BSP
  alias Core.Schemas.BusinessType

  @common_error ["access denied"]
  @default_error ["unexpected error occurred!"]

  def create_business_type(input) do
    if owner_or_manager_validity(input) do
      case BSP.create_business_type(input) do
        {:ok, data} ->
          #        Absinthe.Subscription.publish(CoreWeb.Endpoint, user, create_user: true)
          {:ok, data}

        {:error, changeset} ->
          {:error, changeset}
      end
    else
      {:error, @common_error}
    end
  end

  def update_business_type(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case BSP.get_business_type(id) do
        nil -> {:error, ["business type doesn't exist!"]}
        %{} = business_type -> BSP.update_business_type(business_type, input)
        _ -> {:error, @default_error}
      end
    else
      {:error, @common_error}
    end
  end

  def get_business_type(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case BSP.get_business_type(id) do
        nil -> {:error, ["business type doesn't exist!"]}
        %{} = business_type -> {:ok, business_type}
        _ -> {:error, @default_error}
      end
    else
      {:error, @common_error}
    end
  end

  def delete_business_type(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case BSP.get_business_type(id) do
        nil -> {:error, ["business type doesn't exist!"]}
        %{} = business_type -> BSP.delete_business_type(business_type)
        _ -> {:error, @default_error}
      end
    else
      {:error, @common_error}
    end
  end

  def index(conn, _params) do
    business_types = BSP.list_business_types()
    render(conn, "index.html", business_types: business_types)
  end

  def new(conn, _params) do
    changeset = BSP.change_business_type(%BusinessType{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"business_type" => business_type_params}) do
    case BSP.create_business_type(business_type_params) do
      {:ok, _business_type} ->
        conn
        |> put_flash(:info, "Business type created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    business_type = BSP.get_business_type!(id)
    render(conn, "show.html", business_type: business_type)
  end

  def edit(conn, %{"id" => id}) do
    business_type = BSP.get_business_type!(id)
    changeset = BSP.change_business_type(business_type)
    render(conn, "edit.html", business_type: business_type, changeset: changeset)
  end

  def update(conn, %{"id" => id, "business_type" => business_type_params}) do
    business_type = BSP.get_business_type!(id)

    case BSP.update_business_type(business_type, business_type_params) do
      {:ok, _business_type} ->
        conn
        |> put_flash(:info, "Business type updated successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", business_type: business_type, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    business_type = BSP.get_business_type!(id)
    {:ok, _business_type} = BSP.delete_business_type(business_type)

    conn
    |> put_flash(:info, "Business type deleted successfully.")
  end
end
