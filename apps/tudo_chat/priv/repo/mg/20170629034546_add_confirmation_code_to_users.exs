defmodule Stitch.Repo.Migrations.AddConfirmationCodeToUsers do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:confirmation_code, :string)
    end
  end
end
