defmodule Core.Repo.Migrations.AddRefreshToken do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :refresh_token, :string
    end
  end
end
