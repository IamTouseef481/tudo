defmodule Stitch.Repo.Migrations.AcceptExistingPendingInvitations do
  @moduledoc false
  use Ecto.Migration

  def up do
    execute "update invitations SET accepted = true where accepted = false"
  end

  def down do
  end
end
