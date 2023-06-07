defmodule Stitch.Repo.Migrations.SanitizeLegacyUserRoles do
  @moduledoc false
  use Ecto.Migration

  import Ecto.Query
  alias Stitch.Repo

  @disable_ddl_transaction true

  defmodule User do
    use Ecto.Schema

    schema "users" do
      field(:email, :string)
      field(:onboarded, :boolean, default: false)
      field(:roles, {:array, :string})
    end
  end

  def up do
    query =
      from(
        u in "users",
        select: %{id: u.id, email: u.email, onboarded: u.onboarded, roles: u.roles}
      )

    Repo.transaction(
      fn ->
        query
        |> Repo.stream()
        |> Stream.each(fn user ->
          cond do
            user.onboarded && user.roles != nil && length(user.roles) > 1 ->
              roles =
                user.roles
                |> enforce_guest
                |> enforce_admin

              user
              |> Repo.update_all(set: [roles: roles])

            true ->
              IO.puts("User #{user.email} has no roles. Onboarded: #{user.onboarded}")
          end
        end)
        |> Stream.run()
      end,
      timeout: :infinity
    )
  end

  def down do
  end

  def enforce_guest(roles) do
    if "multi-room-guest" in roles || "single-room-guest" in roles do
      roles -- ["member", "admin"]
    else
      roles
    end
  end

  def enforce_admin(roles) do
    if "admin" in roles do
      roles -- ["member", "multi-room-guest", "single-room-guest"]
    else
      roles
    end
  end
end
