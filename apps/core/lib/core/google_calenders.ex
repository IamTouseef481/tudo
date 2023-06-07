defmodule Core.GoogleCalenders do
  @moduledoc """
  The Jobs context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo
  alias Core.Schemas.{GoogleCalender, Job, Employee}

  def update_google_calender(%GoogleCalender{} = google_calender, attrs) do
    google_calender
    |> GoogleCalender.changeset(attrs)
    |> Repo.update()
  end

  def create_google_calender(attrs \\ %{}) do
    %GoogleCalender{}
    |> GoogleCalender.changeset(attrs)
    |> Repo.insert()
  end

  def get_google_calender_by_job_id(job_id) do
    GoogleCalender
    |> where([gc], gc.job_id == ^job_id)
    |> Repo.one()
  end

  def get_google_calender_by_user_id(user_id) do
    GoogleCalender
    |> join(:left, [gc], j in Job, on: gc.job_id == j.id)
    |> join(:left, [_gc, _j], e in Employee, on: e.user_id == ^user_id)
    |> where([_, j], j.inserted_by == ^user_id)
    |> select([gc], %{cmr_event: gc.cmr_event_id, bsp_event: gc.bsp_event_id})
    |> Repo.all()
  end
end
