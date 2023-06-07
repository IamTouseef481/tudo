defmodule CoreWeb.Controllers.UserController do
  @moduledoc false
  use CoreWeb, :controller

  alias Core.{Accounts, Emails}
  alias Core.Schemas.User
  alias CoreWeb.Helpers.UserHelper
  alias CoreWeb.Utils.CommonFunctions

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  #  defp get_role_scopes(roles) do
  #    roles
  #    |> Enum.flat_map(& &1.role.scopes)
  #    |> Enum.map(&{&1, nil})
  #    |> Map.new()
  #    |> Map.keys()
  #  end

  def update_user_address(user_address, params) do
    case Accounts.update_user_address(user_address, params) do
      {:ok, user_address} -> CommonFunctions.add_geo(user_address)
      {:error, error} -> {:error, error}
    end
  end

  def delete_user_address(user_address) do
    case Accounts.delete_user_address(user_address) do
      {:ok, user_address} -> CommonFunctions.add_geo(user_address)
      {:error, error} -> {:error, error}
    end
  end

  def create_user(params) do
    with {:ok, _last, all} <- UserHelper.register(params),
         %{user: user} <- all do
      {:ok, user}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong."], __ENV__.line)
  end

  def invite_user(params) do
    case UserHelper.invite_user(params) do
      {:ok, _last, _all} -> {:ok, %{meta: ["User Referral Sent Successfully"]}}
      {:error, error} -> {:error, error}
      _ -> {:error, ["unable to send user referral"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong."], __ENV__.line)
  end

  #  def delete_user(id) do
  #    case Accounts.get_user!(id) do
  #      nil -> {:error, ["user doesn't exist!"]}
  #      user -> {:ok, UserHelper.delete(user)}
  ##      _ -> {:ok, ["Something went wrong, try again!"]}
  #    end
  #  end
  def update_user(params) do
    with {:ok, _last, all} <- UserHelper.update(params),
         %{user: user, user_install: install} <- all do
      {:ok, Map.merge(user, %{install: install})}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong."], __ENV__.line)
  end

  def login_user(input, %{status_id: status_id} = user) do
    input = Map.merge(input, %{purpose: "registration_activation"})

    case status_id do
      "confirmed" -> login_counter(user)
      status when status in ["confirmation_pending", "web_registered"] -> email_sage(input, user)
      "admin_confirmation_pending" -> {:ok, "admin_confirmation_pending"}
      _ -> {:error, user}
    end
  end

  def upsert_user_install(%{id: user_id} = _user, %{device_token: device_token} = input) do
    case Accounts.get_user_installs_by_user_and_device_token(user_id, device_token) do
      nil -> create_valid_user_install(Map.merge(input, %{user_id: user_id}))
      %{} = user_install -> update_valid_user_install(user_install, input)
      _user_installs -> {:error, ["Multiple FCM Tokens and Users found"]}
    end
  end

  def upsert_user_install(_, _), do: {:ok, %{}}

  def create_valid_user_install(%{device_token: device_token} = install) do
    case Accounts.get_user_installs_by_device_token(device_token) do
      nil ->
        case Accounts.create_user_installs(install) do
          {:ok, install} -> {:ok, install}
          _ -> {:error, ["Something went wrong, unable to create User installs!"]}
        end

      %{} = user_install ->
        case Accounts.update_user_installs(user_install, install) do
          {:ok, install} -> {:ok, install}
          {:error, _} -> {:error, ["Something went wrong, unable to update User installs!"]}
          _ -> {:error, ["something went wrong while updating user installs!"]}
        end

      _ ->
        {:error, ["Something went wrong while retrieving user install"]}
    end
  end

  def create_valid_user_install(_), do: {:ok, %{}}

  def update_valid_user_install(
        %{user_id: _user_id} = user_install,
        %{device_token: dt} = install
      ) do
    case Accounts.get_user_installs_by_device_token(dt) do
      nil ->
        case Accounts.update_user_installs(user_install, install) do
          {:ok, install} -> {:ok, install}
          _ -> {:error, ["Something went wrong, unable to create User installs!"]}
        end

      %{} = user_install ->
        case Accounts.update_user_installs(user_install, install) do
          {:ok, install} -> {:ok, install}
          {:error, _} -> {:error, ["Something went wrong, unable to update User installs!"]}
          _ -> {:error, ["something went wrong while updating user installs!"]}
        end

      _ ->
        {:error, ["Something went wrong while retrieving user install"]}
    end
  end

  #  def update_valid_user_install(%{device_token: previous_dt}=user_install,
  #        %{device_token: current_dt}=install) do
  #    if previous_dt == current_dt do
  #      case Accounts.update_user_installs(user_install, install) do
  #        {:ok, install} -> {:ok, install}
  #        {:error, error} -> {:error, ["Something went wrong, unable to update User installs!"]}
  #        _ -> {:error, ["something went wrong while updating user installs!"]}
  #      end
  #    else
  #      case Accounts.get_user_installs_by_device_token(current_dt) do
  #        %{} -> {:error, ["can't update user install, this device token already exist"]}
  #        nil ->
  #          case Accounts.update_user_installs(user_install, install) do
  #            {:ok, install} -> {:ok, install}
  #            {:error, error} -> {:error, ["Something went wrong, unable to update User installs!"]}
  #            _ -> {:error, ["something went wrong while updating user installs!"]}
  #          end
  #      end
  #    end
  #  end

  def login_counter(%{sign_in_count: sign_in_count} = user) do
    Accounts.update_user(user, %{sign_in_count: sign_in_count + 1})
    {:ok, "confirmed"}
  end

  def email_sage(input, %{id: id, status_id: status_id, profile: profile} = user) do
    params = Map.merge(input, %{user_id: id, status_id: status_id, profile: profile})

    case UserHelper.login(params) do
      {:ok, _last, _all} -> {:ok, user}
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong."], __ENV__.line)
  end

  @doc """
  register_confirmation/1

  Confirms user registration for newly signed up users.

  TODO - check admin_confirmation_pending
  """

  def register_confirmation(params) do
    params = Map.merge(params, %{purpose: "registration_activation"})

    case Emails.get_random_token!(params) do
      nil ->
        {:error, ["Invalid token"]}

      %{login: login, updated_at: token_sent_at} ->
        time_difference = Timex.diff(DateTime.utc_now(), token_sent_at, :minutes)

        if time_difference < 5 do
          user = Accounts.get_user_by_email(login)
          #        user = Map.merge(user, %{status_id: "confirmed"})
          with true <- user.status_id in ["web_registered", "confirmation_pending"],
               {:ok, user} <-
                 Accounts.update_user(user, %{status_id: "confirmed", sign_in_count: 1}),
               {:ok, jwt_token, _} <- CoreWeb.Guardian.encode_and_sign(user) do
            {:ok, Map.merge(user, %{token: jwt_token})}
          else
            {:error, changeset} -> {:error, changeset}
            _ -> {:error, ["Something went wrong, probably status is already confirmed!"]}
          end
        else
          {:error, ["token expired!"]}
        end
    end
  end

  def forget_password(%{password: _password} = params) do
    params = Map.merge(params, %{purpose: "forget_password"})

    case Emails.get_random_token!(params) do
      nil ->
        {:error, ["Invalid token"]}

      %{login: login} ->
        changeset = %User{} |> User.forget_changeset(params)

        case Accounts.get_user_by_email(login) do
          %{status_id: "confirmation_pending"} = user ->
            if changeset.valid? do
              info = Map.merge(changeset.changes, %{status_id: "confirmed"})
              logger(__MODULE__, info, :info, __ENV__.line)
              Accounts.update_user(user, Map.merge(changeset.changes, %{status_id: "confirmed"}))
            else
              {:error, ["hashing problem"]}
            end

          user ->
            if changeset.valid? do
              Accounts.update_user(user, changeset.changes)
            else
              {:error, ["hashing problem"]}
            end
        end
    end
  end

  def send_token(%{email: email, os: device_type} = input) do
    case validate_device_type(device_type) do
      true ->
        case Accounts.get_user_by_email(email) do
          nil -> {:error, ["this user doesn't exist"]}
          user -> email_sage(input, user)
        end

      _all ->
        {:error, ["Something went wrong, incorrect OS detected"]}
    end
  end

  def create_user_status(input) do
    if CommonFunctions.owner_or_manager_validity(input) do
      case Accounts.create_user_status(input) do
        {:ok, data} -> {:ok, data}
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to insert."], __ENV__.line)
  end

  def get_user_status(%{id: id} = input) do
    if CommonFunctions.owner_or_manager_validity(input) do
      case Accounts.get_user_status(id) do
        nil -> {:error, ["doesn't exist!"]}
        %{} = user_status -> {:ok, user_status}
        _ -> {:error, ["Unexpected error occurred, try again!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["unable to retrieve"], __ENV__.line)
  end

  def update_user_status(%{id: id} = input) do
    if CommonFunctions.owner_or_manager_validity(input) do
      case Accounts.get_user_status(id) do
        nil -> {:error, ["doesn't exist!"]}
        %{} = user_status -> Accounts.update_user_status(user_status, input)
        _ -> {:error, ["Unexpected error occurred, try again!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["unable to update"], __ENV__.line)
  end

  def delete_user_status(%{id: id} = input) do
    if CommonFunctions.owner_or_manager_validity(input) do
      case Accounts.get_user_status(id) do
        nil -> {:error, ["doesn't exist!"]}
        %{} = user_status -> Accounts.delete_user_status(user_status)
        _ -> {:error, ["Unexpected error occurred, try again!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["unable to delete."], __ENV__.line)
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")

      # |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
  end

  @doc """
  validate_device_type/1

  Check if the device type is valid or not.
  Returns true in case of android, ios and admin.
  Returns false otherwise

  TODO - move this function to devices_controller_helper.ex
  """

  def validate_device_type(device_type) do
    case String.downcase(device_type) do
      "android" -> true
      "ios" -> true
      "admin" -> true
      _ -> false
    end
  end

  def delete_cmr(user) do
    with {:ok, last, _all} <- UserHelper.delete_cmr(user) do
      {:ok, last}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong."], __ENV__.line)
  end

  def delete_bsp(user) do
    with {:ok, last, _all} <- UserHelper.delete_bsp(user) do
      {:ok, last}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong."], __ENV__.line)
  end
end
