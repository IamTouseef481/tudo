defmodule Stitch.Repo.Migrations.AddAuthenticatedToIntegrations do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table("integrations") do
      add(:authenticated, :boolean, default: false)
    end
  end
end
