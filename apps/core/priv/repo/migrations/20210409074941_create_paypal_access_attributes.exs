defmodule Core.Repo.Migrations.CreatePayalAccessAttributes do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:paypal_access_attributes) do
      add :access_token, :string
      add :partner_attribution_id, :string

      timestamps()
    end
  end
end
