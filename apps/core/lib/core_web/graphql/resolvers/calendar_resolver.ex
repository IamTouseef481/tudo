defmodule CoreWeb.GraphQL.Resolvers.CalendarResolver do
  @moduledoc false
  import CoreWeb.Utils.CommonFunctions
  alias Core.Calendars
  alias CoreWeb.Controllers.JobController

  def get_calendar_by(_, %{input: %{employee_id: user_id}}, _) do
    {:ok, Calendars.get_calendar_by_employee_id(user_id)}
  end

  def get_calendar_by(_, %{input: %{user_id: user_id}}, _) do
    calendar = Calendars.get_calendar_by_user_id(user_id)

    calendar_jobs =
      calendar.schedule["jobs"]
      |> keys_to_atoms()
      |> JobController.get_cmr_jobs()
      |> Enum.map(fn %{cmr: cmr, branch: branch} = job ->
        # TODO: Branches can be mutiple and deal that case.
        job =
          Map.merge(job, %{branch: Map.from_struct(branch)})
          |> Map.merge(%{cmr: Map.from_struct(cmr)})

        job =
          Map.merge(job, %{
            cmr:
              Map.drop(job.cmr, [
                :language,
                :status,
                :country,
                :user_address,
                :user_installs,
                :__meta__
              ])
          })
          |> Map.merge(%{
            branch:
              Map.drop(job.branch, [
                :location,
                :business,
                :status,
                :licence_issuing_authority,
                :city,
                :country,
                :business_type,
                :employees,
                :branch_services,
                :__meta__
              ])
          })

        if is_nil(Map.get(job, :deal)) do
          job
        else
          deal =
            Map.from_struct(job.deal)
            |> Map.drop([
              :branch,
              :discount_type,
              :promotion_pricing,
              :promotion_status,
              :__meta__
            ])

          Map.merge(job, %{deal: deal})
        end
        |> snake_keys_to_camel()
      end)

    #                    |> Enum.map(&Map.merge(%Core.Schemas.Job{}, &1))
    {_, calendar} = get_and_update_in(calendar.schedule["jobs"], &{&1, calendar_jobs})
    {:ok, calendar}
  end

  def get_calendar_by(_, _, _) do
    {:ok, %{}}
  end
end
