defmodule Stitch.Repo.Migrations.RemoveTextContentMetaFromMessages do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:messages) do
      remove(:text_content_meta)
    end
  end
end
