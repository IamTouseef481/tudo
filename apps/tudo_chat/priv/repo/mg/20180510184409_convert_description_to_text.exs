defmodule Stitch.Repo.Migrations.ConvertDescriptionToText do
  @moduledoc false
  use Ecto.Migration

  def up do
    alter table(:groups) do
      modify(:description, :text)
    end
  end

  def down do
    alter table(:groups) do
      modify(:description, :string)
    end
  end
end
