defmodule CoreWeb.GraphQL.Resolvers.UserResolver do
  @moduledoc false
  use CoreWeb.GraphQL, :resolver
  alias Core.{Accounts, Regions}
  alias Core.Schemas.UserInstalls
  alias CoreWeb.Controllers.UserController
  alias CoreWeb.Helpers.UserHelper, as: Account
  alias CoreWeb.Utils.String

  @default_error ["something went wrong"]

  def users(_, _, _) do
    users = Accounts.list_users()
    {:ok, users.entries}
  end

  def user_statuses(_, _, _) do
    {:ok, Accounts.list_user_statuses()}
  end

  def invite_user(_, %{input: input}, %{context: %{current_user: %{id: user_id}}}) do
    params = Map.merge(input, %{user_id: user_id})

    case UserController.invite_user(params) do
      {:ok, msg} -> {:ok, msg}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, @default_error}
    end
  end

  def invite_user(_, _, _), do: {:error, ["invalid input"]}

  def create_straight_user(_, %{input: input}, _) do
    case create_straight_user(input) do
      {:ok, _, %{user: user}} ->
        #         {:ok, jwt_token, _} <- CoreWeb.Guardian.encode_and_sign(user) do
        #      {:ok, Map.merge(user, %{token: jwt_token})}
        {:ok, user}

      {:error, changeset} ->
        {:error, changeset}

      _ ->
        {:error, @default_error}
    end
  end

  def create_user(_, %{input: input}, _) do
    case UserController.create_user(input) do
      {:ok, user} ->
        #         {:ok, jwt_token, _} <- CoreWeb.Guardian.encode_and_sign(user) do
        #      {:ok, Map.merge(user, %{token: jwt_token})}
        {:ok, user}

      {:error, changeset} ->
        {:error, changeset}

      _ ->
        {:error, @default_error}
    end
  end

  def delete_user(_, %{input: %{delete_confirmation: true}}, %{
        context: %{current_user: current_user}
      }) do
    if current_user.acl_role_id == ["cmr"] do
      case UserController.delete_cmr(current_user) do
        {:ok, message} ->
          {:ok, %{message: message}}

        {:error, changeset} ->
          {:error, changeset}

        _ ->
          {:error, @default_error}
      end
    else
      case UserController.delete_bsp(current_user) do
        {:ok, message} ->
          {:ok, %{message: message}}

        {:error, changeset} ->
          {:error, changeset}

        _ ->
          {:error, @default_error}
      end
    end
  end

  def delete_user(_, _, _), do: {:error, "No need to delete"}

  def update_user(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user: current_user})

    case UserController.update_user(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def login_user(_, %{input: input}, _) do
    with {:ok, user} <- Accounts.authenticate(input),
         {:ok, _} <- UserController.login_user(input, user),
         {:ok, _} <- UserController.upsert_user_install(user, input),
         {:ok, jwt_token, _} <- CoreWeb.Guardian.encode_and_sign(user) do
      user_addresses = Accounts.get_user_address_by(user.id)

      addresses =
        Enum.map(user_addresses, fn %{geo_location: location} = address ->
          case location do
            %{coordinates: {long, lat}} ->
              Map.merge(address, %{geo: %{lat: lat, long: long}})

            _ ->
              address
          end
        end)

      user = Map.merge(user, %{user_address: addresses})

      if user.status_id == "confirmed",
        do: {:ok, %{token: jwt_token, user: user}},
        else: {:error, ["user status is not confirmed!"]}
    else
      {:not_exist, data} -> {:error, data}
      {:error, ["token already sent!"]} -> {:error, ["User status is not confirmed"]}
      {:error, %{} = data} -> {:ok, %{user: Map.merge(data, %{token: nil})}}
      {:error, error} -> {:error, error}
      _ -> {:error, ["Something went wrong"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def logout(_, %{input: %{token: token, fcm_token: fcm_token}}, %{context: %{current_user: user}}) do
    case CoreWeb.Guardian.revoke(token) do
      {:ok, _} -> delete_user_install_through_fcm_token(user.id, fcm_token)
      _ -> {:error, ["unable to logout"]}
    end
  end

  def logout(_, %{input: %{token: token, device_token: device_token}}, %{
        context: %{current_user: user}
      }) do
    case CoreWeb.Guardian.revoke(token) do
      {:ok, _} -> delete_user_install_through_device_token(user.id, device_token)
      _ -> {:error, ["unable to logout"]}
    end
  end

  def get_user(_, _, %{context: %{current_user: current_user}}) do
    {:ok, addresses} = get_user_addresses(nil, %{input: %{user_id: current_user.id}}, nil)
    {:ok, Map.merge(current_user, %{user_address: addresses})}
  end

  def get_user_addresses(_, %{input: %{user_id: user_id}}, _) do
    {:ok, Accounts.get_user_address_by(user_id) |> Enum.map(&add_geo(&1))}
  end

  def get_user_by(_, %{input: %{email: email}}, _) do
    case Accounts.get_user_by_email(email) do
      nil ->
        {:error, ["Not a TUDO user"]}

      user ->
        {:ok,
         %{
           id: user.id,
           first_name: user.profile["first_name"],
           last_name: user.profile["last_name"],
           phone: user.mobile
         }}
    end
  end

  def create_user_address(_, %{input: %{primary: true} = input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{user_id: current_user.id})

    case Accounts.get_user_address_by(current_user.id) do
      [] ->
        create_address(input)

      addresses ->
        Enum.each(addresses, fn address ->
          if address.primary do
            UserController.update_user_address(address, %{primary: false})
          end
        end)

        create_address(input)
    end
  end

  def create_user_address(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case Accounts.create_user_address(input) do
      {:ok, user_address} -> {:ok, add_geo(user_address)}
      {:error, error} -> {:error, error}
    end
  end

  def create_address(input) do
    case Accounts.create_user_address(input) do
      {:ok, user_address} -> {:ok, add_geo(user_address)}
      {:error, error} -> {:error, error}
    end
  end

  def create_user_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case UserController.create_user_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_user_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case UserController.get_user_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def update_user_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case UserController.update_user_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_user_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case UserController.delete_user_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_user_address(_, %{input: %{id: id, primary: true} = params}, %{
        context: %{current_user: current_user}
      }) do
    params = Map.merge(params, %{user_id: current_user.id})

    case Accounts.get_user_address_by(current_user.id) do
      [] ->
        {:error, ["user address doesn't exist!"]}

      addresses ->
        Enum.each(addresses, fn address ->
          if address.primary do
            UserController.update_user_address(address, %{primary: false})
          end
        end)
    end

    case Accounts.get_user_address(id) do
      nil -> {:error, ["user address doesn't exist!"]}
      user_address -> {:ok, UserController.update_user_address(user_address, params)}
    end
  end

  def update_user_address(_, %{input: %{id: id} = params}, %{
        context: %{current_user: current_user}
      }) do
    params = Map.merge(params, %{user_id: current_user.id})

    case Accounts.get_user_address(id) do
      nil -> {:error, ["user address doesn't exist!"]}
      user_address -> {:ok, UserController.update_user_address(user_address, params)}
    end
  end

  def delete_user_address(_, %{input: %{address_id: id}}, _) do
    case Accounts.get_user_address(id) do
      nil -> {:error, ["user address doesn't exist!"]}
      user_address -> {:ok, UserController.delete_user_address(user_address)}
    end
  end

  def register_confirmation(_, %{input: input}, _) do
    UserController.register_confirmation(input)
  end

  def delete_user_install_through_fcm_token(user_id, fcm_token) do
    case Accounts.get_user_installs_by_user_and_fcm_token(user_id, fcm_token) do
      [] ->
        {:ok, %{meta: %{message: "Logout successful"}}}

      [install] ->
        Accounts.delete_user_installs(install)
        {:ok, %{meta: %{message: "Logout successful"}}}

      user_installs when is_list(user_installs) ->
        Enum.each(user_installs, &Accounts.delete_user_installs(&1))
        {:ok, %{meta: %{message: "Logout successful"}}}
    end
  end

  def delete_user_install_through_device_token(user_id, device_token) do
    case Accounts.get_user_installs_by_user_and_device_token(user_id, device_token) do
      nil ->
        {:ok, %{meta: %{message: "Logout successful"}}}

      %{} = install ->
        Accounts.delete_user_installs(install)
        {:ok, %{meta: %{message: "Logout successful"}}}

      user_installs when is_list(user_installs) ->
        Enum.each(user_installs, &Accounts.delete_user_installs(&1))
        {:ok, %{meta: %{message: "Logout successful"}}}
    end
  end

  def forget_password(_, %{input: input}, _) do
    case UserController.forget_password(input) do
      {:ok, user} -> {:ok, user}
      {:error, data} -> {:error, data}
      _ -> {:error, @default_error}
    end
  end

  def send_token(_, %{input: input}, _) do
    case UserController.send_token(input) do
      {:ok, _} ->
        {:ok,
         %{
           meta: %{
             server_time: DateTime.utc_now(),
             message: "Token sent successfully!"
           }
         }}

      {:error, data} ->
        {:error, data}

      _ ->
        {:error, @default_error}
    end
  end

  #  with minimal information
  def create_straight_user(input) do
    %{country_id: country_id} =
      input =
      if Map.get(input, :country_id) do
        input
      else
        Map.merge(input, %{country_id: 2})
      end

    input =
      if Map.has_key?(input, :mobile) do
        input
      else
        Map.merge(input, %{
          mobile: input[:phone],
          profile: %{
            first_name: get_in(input, [:profile, :first_name]),
            last_name: get_in(input, [:profile, :last_name])
          }
        })
      end

    case Regions.get_countries(country_id) do
      nil ->
        {:error, ["country doesn't exist"]}

      %{language_id: language_id} ->
        password = String.generate_random_password()

        input =
          Map.merge(input, %{
            language_id: language_id,
            status_id: "web_registered",
            password: password
          })

        Account.straight_register(input)
    end
  end

  def update_user_install(_, %{input: input}, %{context: %{current_user: current_user}}) do
    with %UserInstalls{} = user_install <-
           Accounts.get_user_installs_by_user_and_device_token(
             current_user.id,
             input.device_token
           ),
         {:ok, data} <- Accounts.update_user_installs_fcm_token(user_install, input) do
      {:ok, data}
    else
      nil -> {:error, "No user install for update"}
      {:error, error} -> {:error, error}
    end
  end
end
