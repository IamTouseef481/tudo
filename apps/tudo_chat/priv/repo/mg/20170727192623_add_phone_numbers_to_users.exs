defmodule Stitch.Repo.Migrations.AddPhoneNumbersToUsers do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :phone_number, :string
    end
  end
end
