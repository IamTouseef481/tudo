defmodule Core.Repo.Migrations.UpdateLocationToLongLat do
  use Ecto.Migration

  alias Core.Schemas.{
    Branch,
    Lead,
    Employee,
    Job,
    UserAddress,
    CharitableOrganization,
    JobRequest,
    BiddingJob
  }

  alias Core.{Repo, BSP, Leads, Employees, Jobs, Accounts, Payments, Bids}

  def change do
    # ...................................................................................
    Repo.all(Branch)
    |> Enum.each(fn %{location: location} = branch ->
      BSP.update_branch(branch, %{location: location |> check_nil_location()})
    end)

    # ....................................................................................
    Repo.all(Lead)
    |> Enum.each(fn %{location: location} = lead ->
      Leads.update_lead(lead, %{location: location |> check_nil_location()})
    end)

    # .....................................................................................
    Repo.all(Employee)
    |> Enum.each(fn %{current_location: current_location} = employee ->
      Employees.update_employee(employee, %{
        current_location: current_location |> check_nil_location()
      })
    end)

    # ........................................................................................
    Repo.all(Job)
    |> Enum.each(fn %{
                      location_src: location_src,
                      location_dest: location_dest
                    } = job ->
      Jobs.update_job(job, %{
        location_src: location_src |> check_nil_location(),
        location_dest: location_dest |> check_nil_location()
      })
    end)

    # ........................................................................................
    Repo.all(UserAddress)
    |> Enum.each(fn %{geo_location: geo_location} = user_address ->
      Accounts.update_user_address(user_address, %{
        geo_location: geo_location |> check_nil_location()
      })
    end)

    # .........................................................................................
    Repo.all(JobRequest)
    |> Enum.each(fn %{
                      location_src: location_src,
                      location_dest: location_dest,
                      bsp_current_location: bsp_current_location
                    } = job_request ->
      Jobs.update_job_request(job_request, %{
        location_src: location_src |> check_nil_location(),
        location_dest: location_dest |> check_nil_location(),
        bsp_current_location: bsp_current_location |> check_nil_location()
      })
    end)

    # ..............................................................................................
    Repo.all(CharitableOrganization)
    |> Enum.each(fn %{location: location} = charitable_organization ->
      Payments.update_charitable_organization(charitable_organization, %{
        location: location |> check_nil_location()
      })
    end)

    # ....................................................................................................
    Repo.all(BiddingJob)
    |> Enum.each(fn %{location_dest: location_dest} = bidding_job ->
      Bids.update_bidding_job(bidding_job, %{location_dest: location_dest |> check_nil_location()})
    end)
  end

  # ..............................................................................................
  def check_nil_location(location) do
    if is_nil(location) do
      nil
    else
      %Geo.Point{coordinates: {lat, long}} = location
      %Geo.Point{coordinates: {long, lat}}
    end
  end
end
