defmodule Core.Repo.Migrations.AddStatusAuthorize do
  use Ecto.Migration
  alias Core.{Payments, Jobs}

  def change do
    case Payments.get_payment_status("authorize") do
      nil -> Payments.create_payment_status(%{id: "authorize", description: "Authorize"})
      _data -> :do_nothing
    end

    case Jobs.get_job_status("authorize") do
      nil -> Jobs.create_job_status(%{id: "authorize", description: "Authorize"})
      _data -> :do_nothing
    end
  end
end
