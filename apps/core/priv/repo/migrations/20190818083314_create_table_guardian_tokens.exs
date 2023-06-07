defmodule Core.Repo.Migrations.CreateTableGuardianTokens do
  @moduledoc false
  use Ecto.Migration
  @table :guardian_tokens
  def change do
    create table(@table, primary_key: false) do
      add(:jti, :string, primary_key: true)
      add(:aud, :string, primary_key: true)
      add(:typ, :string)
      add(:iss, :string)
      add(:sub, :string)
      add(:exp, :bigint)
      add(:jwt, :text)
      add(:claims, :jsonb)

      timestamps()
    end

    create(index(:guardian_tokens, [:jwt]))
    create(index(:guardian_tokens, [:sub]))
    create(index(:guardian_tokens, [:jti]))
  end
end
