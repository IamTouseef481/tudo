defmodule Core.Repo.Migrations.CreateTableBusinessTermsAndConditions do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:business_terms_and_conditions) do
      add :type, :string
      add :text, :text
      add :url, :string
      add :start_date, :utc_datetime, default: fragment("now()")
      add :end_date, :utc_datetime, default: fragment("timestamp '9999-12-31 23:59:59.999'")

      timestamps()
    end
  end
end
