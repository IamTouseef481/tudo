defmodule CoreWeb.Controllers.BusinessController do
  @moduledoc false
  use CoreWeb, :controller

  alias Core.BSP
  alias CoreWeb.Helpers.BusinessHelper

  def create_business(input) do
    with {:ok, _last, all} <- BusinessHelper.create_business(input),
         %{
           business: business,
           branch: %{
             name: branch_name,
             phone: branch_phone,
             address: %{address: address},
             profile_pictures: profile_pictures,
             id: branch_id
           }
         } <- all do
      Map.merge(business, %{
        branch_name: branch_name,
        branch_phone: branch_phone,
        branch_address: address,
        profile_pictures: profile_pictures,
        branch_id: branch_id
      })
      |> ok()
    else
      {:error, err} -> err |> error()
      err -> err |> error()
    end
  rescue
    exception ->
      logger(__MODULE__, exception, decode_rescue_error(exception), __ENV__.line)
  end

  def update_business(%{profile_pictures: profile_pictures} = input) do
    profile_pictures = CoreWeb.Controllers.ImageController.upload(profile_pictures, "business")

    input
    |> put(:profile_pictures, profile_pictures)
    |> updates_business()
  end

  def update_business(%{rest_profile_pictures: rest_profile_pictures} = input) do
    input
    |> put(:profile_pictures, rest_profile_pictures)
    |> updates_business()
  end

  def update_business(input) do
    input
    |> updates_business()
  end

  defp updates_business(%{id: id, current_user: %{id: user_id}} = input) do
    case BSP.get_business_by_user_id_and_business_id(user_id, id) do
      [] ->
        error(["Business doesn't exist for that user"])

      [business] ->
        input = make_business_settings_input(business.settings, input)

        case BSP.update_business(business, input) do
          {:ok, business} ->
            settings = business.settings

            keys = Map.keys(settings)

            if is_binary(hd(keys)) do
              settings
              |> keys_to_atoms()
              |> then(fn setting -> business |> put(:settings, setting) end)
              |> ok()
            else
              business |> ok()
            end

          {:error, err} ->
            err |> error()
        end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, decode_rescue_error(exception), __ENV__.line)
  end

  def make_business_settings_input(settings, input) do
    settings =
      settings
      |> keys_to_atoms()

    case input do
      %{settings: input_settings} ->
        settings
        |> Map.merge(input_settings)
        |> then(fn merged_settings -> input |> put(:settings, merged_settings) end)

      _ ->
        input
    end
  end

  def delete_business(%{id: id, user: %{id: user_id}}) do
    case BSP.get_business_by_user_id_and_business_id(user_id, id) do
      [] -> error(["Business doesn't exist for that user"])
      [business] -> BSP.delete_business(business)
    end
  end
end
