defmodule CoreWeb.Utils.SocketHandler do
  @moduledoc false

  def job_socket_processing(%{branch: branch} = job) do
    job_data = process_socket(job)

    branch =
      Map.drop(branch, [
        :business_type,
        :branch_services,
        :business,
        :city,
        :employees,
        :licence_issuing_authority,
        :location,
        :country,
        :__meta__,
        :__struct__
      ])

    branch =
      if job.branch.location != nil do
        {long, lat} = job.branch.location.coordinates
        Map.merge(branch, %{location: %{lat: lat, long: long}})
      else
        branch
      end

    Map.merge(job_data, %{branch: branch})
  end

  def job_socket_processing(%{branches: branches} = job) when is_list(branches) do
    job_data = process_socket(job)

    branches =
      Enum.map(branches, fn branch ->
        branch =
          Map.drop(branch, [
            :business_type,
            :branch_services,
            :business,
            :city,
            :employees,
            :licence_issuing_authority,
            :location,
            :country,
            :__meta__,
            :__struct__
          ])

        if is_nil(Map.get(branch, :geo)) == false do
          #          {long, lat} = branch.location.coordinates
          Map.merge(branch, %{location: branch.geo})
        else
          branch
        end
      end)

    Map.merge(job_data, %{branches: branches})
  end

  def job_socket_processing(job) do
    process_socket(job)
  end

  defp process_socket(job) do
    job_data =
      Map.drop(job, [
        :job_cmr_status,
        :job_bsp_status,
        :job_status,
        :job_category,
        :job_google_calender,
        :__meta__,
        :__struct__
      ])

    cmr = Map.drop(job.cmr, [:status, :country, :language, :user_address, :__meta__, :__struct__])

    job_dest_location =
      if job.location_dest != nil do
        {long, lat} = job.location_dest.coordinates
        %{lat: lat, long: long}
      else
        nil
      end

    job_src_location =
      if job.location_src != nil do
        {long, lat} = job.location_src.coordinates
        %{lat: lat, long: long}
      else
        nil
      end

    Map.merge(job_data, %{
      cmr: cmr,
      location_dest: job_dest_location,
      location_src: job_src_location
    })
  end
end
