defmodule Stitch.Repo.Migrations.AddWebhookTokenToIntegrations do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:integrations) do
      add(:webhook_token, :text)
    end
  end
end
