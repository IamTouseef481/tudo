defmodule Core.Repo.Migrations.SetDefaultNullForBranchServiceId do
  use Ecto.Migration
  alias Core.Schemas.{Job}
  alias Core.{Repo, Jobs}

  def change do
    Repo.all(Job)
    |> Enum.each(fn %{branch_service_ids: branch_service_ids} = job ->
      if branch_service_ids == [] do
        Jobs.update_job(job, %{branch_service_ids: nil})
      end
    end)
  end
end
