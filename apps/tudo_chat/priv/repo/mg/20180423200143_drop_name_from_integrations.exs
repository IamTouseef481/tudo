defmodule Stitch.Repo.Migrations.DropNameFromIntegrations do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:integrations) do
      remove :name
    end
  end
end
