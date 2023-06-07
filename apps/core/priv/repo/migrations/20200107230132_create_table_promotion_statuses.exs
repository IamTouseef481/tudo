defmodule Core.Repo.Migrations.CreateTablePromotionStatuses do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:promotion_statuses, primary_key: false) do
      add :id, :string, null: false, primary_key: true
      add :title, :string
      add :description, :text
    end
  end
end
