defmodule Core.JobsTest do
  use Core.DataCase

  alias Core.Jobs

  describe "job_categories" do
    alias Core.Schemas.JobCategory

    @valid_attrs %{description: "some description", name: "some name"}
    @update_attrs %{description: "some updated description", name: "some updated name"}
    @invalid_attrs %{description: nil, name: nil}

    def job_category_fixture(attrs \\ %{}) do
      {:ok, job_category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Jobs.create_job_category()

      job_category
    end

    test "list_job_categories/0 returns all job_categories" do
      job_category = job_category_fixture()
      assert Jobs.list_job_categories() == [job_category]
    end

    test "get_job_category!/1 returns the job_category with given id" do
      job_category = job_category_fixture()
      assert Jobs.get_job_category!(job_category.id) == job_category
    end

    test "create_job_category/1 with valid data creates a job_category" do
      assert {:ok, %JobCategory{} = job_category} = Jobs.create_job_category(@valid_attrs)
      assert job_category.description == "some description"
      assert job_category.name == "some name"
    end

    test "create_job_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job_category(@invalid_attrs)
    end

    test "update_job_category/2 with valid data updates the job_category" do
      job_category = job_category_fixture()

      assert {:ok, %JobCategory{} = job_category} =
               Jobs.update_job_category(job_category, @update_attrs)

      assert job_category.description == "some updated description"
      assert job_category.name == "some updated name"
    end

    test "update_job_category/2 with invalid data returns error changeset" do
      job_category = job_category_fixture()
      assert {:error, %Ecto.Changeset{}} = Jobs.update_job_category(job_category, @invalid_attrs)
      assert job_category == Jobs.get_job_category!(job_category.id)
    end

    test "delete_job_category/1 deletes the job_category" do
      job_category = job_category_fixture()
      assert {:ok, %JobCategory{}} = Jobs.delete_job_category(job_category)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_job_category!(job_category.id) end
    end

    test "change_job_category/1 returns a job_category changeset" do
      job_category = job_category_fixture()
      assert %Ecto.Changeset{} = Jobs.change_job_category(job_category)
    end
  end

  describe "jobs" do
    alias Core.Schemas.Job

    @valid_attrs %{
      service_id: [],
      location_dest: "some location_dest",
      bsp_to_cmr_comments: "some bsp_to_cmr_comments",
      parent_service_id: 42,
      cmr_to_bsp_rating_professional: 120.5,
      expected_work_duration: ~T[14:00:00],
      rejected_at: ~N[2010-04-17 14:00:00],
      cost: 120.5,
      cmr_to_bsp_rating: 120.5,
      status_id: "some status_id",
      gallery: %{},
      initial_cost: 120.5,
      confirmed_at: ~N[2010-04-17 14:00:00],
      title: "some title",
      location_src_name: "some location_src_name",
      cmr_to_bsp_rating_communication: 120.5,
      description: "some description",
      basic_fee: 120.5,
      called_at: ~N[2010-04-17 14:00:00],
      completed_at: ~N[2010-04-17 14:00:00],
      work_duration_at_working: ~T[14:00:00],
      is_flexible: true,
      arrive_at: ~N[2010-04-17 14:00:00],
      fee: 120.5,
      location_dest_zone_id: "some location_dest_zone_id",
      cost_at_complete: 120.5,
      cancel_reason: "some cancel_reason",
      location_src_zone_id: "some location_src_zone_id",
      approved_at: ~N[2010-04-17 14:00:00],
      item_fee: 120.5,
      cancelled_at: ~N[2010-04-17 14:00:00],
      started_working_at: ~N[2010-04-17 14:00:00],
      cost_at_working: 120.5,
      bsp_to_cmr_rating: 120.5,
      cmr_to_bsp_comments: "some cmr_to_bsp_comments",
      cmr_to_bsp_rating_friendly: 120.5,
      history: %{},
      dynamic_fields: %{},
      service_params: %{},
      location_src: "some location_src",
      deleted_at: ~N[2010-04-17 14:00:00]
    }
    @update_attrs %{
      service_id: [],
      location_dest: "some updated location_dest",
      bsp_to_cmr_comments: "some updated bsp_to_cmr_comments",
      parent_service_id: 43,
      cmr_to_bsp_rating_professional: 456.7,
      expected_work_duration: ~T[15:01:01],
      rejected_at: ~N[2011-05-18 15:01:01],
      cost: 456.7,
      cmr_to_bsp_rating: 456.7,
      status_id: "some updated status_id",
      gallery: %{},
      initial_cost: 456.7,
      confirmed_at: ~N[2011-05-18 15:01:01],
      title: "some updated title",
      location_src_name: "some updated location_src_name",
      cmr_to_bsp_rating_communication: 456.7,
      description: "some updated description",
      basic_fee: 456.7,
      called_at: ~N[2011-05-18 15:01:01],
      completed_at: ~N[2011-05-18 15:01:01],
      work_duration_at_working: ~T[15:01:01],
      is_flexible: false,
      arrive_at: ~N[2011-05-18 15:01:01],
      fee: 456.7,
      location_dest_zone_id: "some updated location_dest_zone_id",
      cost_at_complete: 456.7,
      cancel_reason: "some updated cancel_reason",
      location_src_zone_id: "some updated location_src_zone_id",
      approved_at: ~N[2011-05-18 15:01:01],
      item_fee: 456.7,
      cancelled_at: ~N[2011-05-18 15:01:01],
      started_working_at: ~N[2011-05-18 15:01:01],
      cost_at_working: 456.7,
      bsp_to_cmr_rating: 456.7,
      cmr_to_bsp_comments: "some updated cmr_to_bsp_comments",
      cmr_to_bsp_rating_friendly: 456.7,
      history: %{},
      dynamic_fields: %{},
      service_params: %{},
      location_src: "some updated location_src",
      deleted_at: ~N[2011-05-18 15:01:01]
    }
    @invalid_attrs %{
      service_id: nil,
      location_dest: nil,
      bsp_to_cmr_comments: nil,
      parent_service_id: nil,
      cmr_to_bsp_rating_professional: nil,
      expected_work_duration: nil,
      rejected_at: nil,
      cost: nil,
      cmr_to_bsp_rating: nil,
      status_id: nil,
      gallery: nil,
      initial_cost: nil,
      confirmed_at: nil,
      title: nil,
      location_src_name: nil,
      cmr_to_bsp_rating_communication: nil,
      description: nil,
      basic_fee: nil,
      called_at: nil,
      completed_at: nil,
      work_duration_at_working: nil,
      is_flexible: nil,
      arrive_at: nil,
      fee: nil,
      location_dest_zone_id: nil,
      cost_at_complete: nil,
      cancel_reason: nil,
      location_src_zone_id: nil,
      approved_at: nil,
      item_fee: nil,
      cancelled_at: nil,
      started_working_at: nil,
      cost_at_working: nil,
      bsp_to_cmr_rating: nil,
      cmr_to_bsp_comments: nil,
      cmr_to_bsp_rating_friendly: nil,
      history: nil,
      dynamic_fields: nil,
      service_params: nil,
      location_src: nil,
      deleted_at: nil
    }

    def job_fixture(attrs \\ %{}) do
      {:ok, job} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Jobs.create_job()

      job
    end

    test "list_jobs/0 returns all jobs" do
      job = job_fixture()
      assert Jobs.list_jobs() == [job]
    end

    test "get_job!/1 returns the job with given id" do
      job = job_fixture()
      assert Jobs.get_job!(job.id) == job
    end

    test "create_job/1 with valid data creates a job" do
      assert {:ok, %Job{} = job} = Jobs.create_job(@valid_attrs)
      assert job.deleted_at == ~N[2010-04-17 14:00:00]
      assert job.location_src == "some location_src"
      assert job.service_params == %{}
      assert job.dynamic_fields == %{}
      assert job.history == %{}
      assert job.cmr_to_bsp_rating_friendly == 120.5
      assert job.cmr_to_bsp_comments == "some cmr_to_bsp_comments"
      assert job.bsp_to_cmr_rating == 120.5
      assert job.cost_at_working == 120.5
      assert job.started_working_at == ~N[2010-04-17 14:00:00]
      assert job.cancelled_at == ~N[2010-04-17 14:00:00]
      assert job.item_fee == 120.5
      assert job.approved_at == ~N[2010-04-17 14:00:00]
      assert job.location_src_zone_id == "some location_src_zone_id"
      assert job.cancel_reason == "some cancel_reason"
      assert job.cost_at_complete == 120.5
      assert job.location_dest_zone_id == "some location_dest_zone_id"
      assert job.fee == 120.5
      assert job.arrive_at == ~N[2010-04-17 14:00:00]
      assert job.is_flexible == true
      assert job.work_duration_at_working == ~T[14:00:00]
      assert job.completed_at == ~N[2010-04-17 14:00:00]
      assert job.called_at == ~N[2010-04-17 14:00:00]
      assert job.basic_fee == 120.5
      assert job.description == "some description"
      assert job.cmr_to_bsp_rating_communication == 120.5
      assert job.location_src_name == "some location_src_name"
      assert job.title == "some title"
      assert job.confirmed_at == ~N[2010-04-17 14:00:00]
      assert job.initial_cost == 120.5
      assert job.gallery == %{}
      assert job.status_id == "some status_id"
      assert job.cmr_to_bsp_rating == 120.5
      assert job.cost == 120.5
      assert job.rejected_at == ~N[2010-04-17 14:00:00]
      assert job.expected_work_duration == ~T[14:00:00]
      assert job.cmr_to_bsp_rating_professional == 120.5
      assert job.parent_service_id == 42
      assert job.bsp_to_cmr_comments == "some bsp_to_cmr_comments"
      assert job.location_dest == "some location_dest"
      assert job.service_id == []
    end

    test "create_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job(@invalid_attrs)
    end

    test "update_job/2 with valid data updates the job" do
      job = job_fixture()
      assert {:ok, %Job{} = job} = Jobs.update_job(job, @update_attrs)
      assert job.deleted_at == ~N[2011-05-18 15:01:01]
      assert job.location_src == "some updated location_src"
      assert job.service_params == %{}
      assert job.dynamic_fields == %{}
      assert job.history == %{}
      assert job.cmr_to_bsp_rating_friendly == 456.7
      assert job.cmr_to_bsp_comments == "some updated cmr_to_bsp_comments"
      assert job.bsp_to_cmr_rating == 456.7
      assert job.cost_at_working == 456.7
      assert job.started_working_at == ~N[2011-05-18 15:01:01]
      assert job.cancelled_at == ~N[2011-05-18 15:01:01]
      assert job.item_fee == 456.7
      assert job.approved_at == ~N[2011-05-18 15:01:01]
      assert job.location_src_zone_id == "some updated location_src_zone_id"
      assert job.cancel_reason == "some updated cancel_reason"
      assert job.cost_at_complete == 456.7
      assert job.location_dest_zone_id == "some updated location_dest_zone_id"
      assert job.fee == 456.7
      assert job.arrive_at == ~N[2011-05-18 15:01:01]
      assert job.is_flexible == false
      assert job.work_duration_at_working == ~T[15:01:01]
      assert job.completed_at == ~N[2011-05-18 15:01:01]
      assert job.called_at == ~N[2011-05-18 15:01:01]
      assert job.basic_fee == 456.7
      assert job.description == "some updated description"
      assert job.cmr_to_bsp_rating_communication == 456.7
      assert job.location_src_name == "some updated location_src_name"
      assert job.title == "some updated title"
      assert job.confirmed_at == ~N[2011-05-18 15:01:01]
      assert job.initial_cost == 456.7
      assert job.gallery == %{}
      assert job.status_id == "some updated status_id"
      assert job.cmr_to_bsp_rating == 456.7
      assert job.cost == 456.7
      assert job.rejected_at == ~N[2011-05-18 15:01:01]
      assert job.expected_work_duration == ~T[15:01:01]
      assert job.cmr_to_bsp_rating_professional == 456.7
      assert job.parent_service_id == 43
      assert job.bsp_to_cmr_comments == "some updated bsp_to_cmr_comments"
      assert job.location_dest == "some updated location_dest"
      assert job.service_id == []
    end

    test "update_job/2 with invalid data returns error changeset" do
      job = job_fixture()
      assert {:error, %Ecto.Changeset{}} = Jobs.update_job(job, @invalid_attrs)
      assert job == Jobs.get_job!(job.id)
    end

    test "delete_job/1 deletes the job" do
      job = job_fixture()
      assert {:ok, %Job{}} = Jobs.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = job_fixture()
      assert %Ecto.Changeset{} = Jobs.change_job(job)
    end
  end

  describe "job_statuses" do
    alias Core.Schemas.JobStatus

    @valid_attrs %{description: "some description", name: "some name"}
    @update_attrs %{description: "some updated description", name: "some updated name"}
    @invalid_attrs %{description: nil, name: nil}

    def job_status_fixture(attrs \\ %{}) do
      {:ok, job_status} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Jobs.create_job_status()

      job_status
    end

    test "list_job_statuses/0 returns all job_statuses" do
      job_status = job_status_fixture()
      assert Jobs.list_job_statuses() == [job_status]
    end

    test "get_job_status!/1 returns the job_status with given id" do
      job_status = job_status_fixture()
      assert Jobs.get_job_status!(job_status.id) == job_status
    end

    test "create_job_status/1 with valid data creates a job_status" do
      assert {:ok, %JobStatus{} = job_status} = Jobs.create_job_status(@valid_attrs)
      assert job_status.description == "some description"
      assert job_status.name == "some name"
    end

    test "create_job_status/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job_status(@invalid_attrs)
    end

    test "update_job_status/2 with valid data updates the job_status" do
      job_status = job_status_fixture()
      assert {:ok, %JobStatus{} = job_status} = Jobs.update_job_status(job_status, @update_attrs)
      assert job_status.description == "some updated description"
      assert job_status.name == "some updated name"
    end

    test "update_job_status/2 with invalid data returns error changeset" do
      job_status = job_status_fixture()
      assert {:error, %Ecto.Changeset{}} = Jobs.update_job_status(job_status, @invalid_attrs)
      assert job_status == Jobs.get_job_status!(job_status.id)
    end

    test "delete_job_status/1 deletes the job_status" do
      job_status = job_status_fixture()
      assert {:ok, %JobStatus{}} = Jobs.delete_job_status(job_status)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_job_status!(job_status.id) end
    end

    test "change_job_status/1 returns a job_status changeset" do
      job_status = job_status_fixture()
      assert %Ecto.Changeset{} = Jobs.change_job_status(job_status)
    end
  end

  describe "job_history" do
    alias Core.Schemas.JobHistory

    @valid_attrs %{
      inserted_by: 42,
      invoice_id: 42,
      payment_id: 42,
      reason: "some reason",
      updated_by: 42,
      user_role: "some user_role"
    }
    @update_attrs %{
      inserted_by: 43,
      invoice_id: 43,
      payment_id: 43,
      reason: "some updated reason",
      updated_by: 43,
      user_role: "some updated user_role"
    }
    @invalid_attrs %{
      inserted_by: nil,
      invoice_id: nil,
      payment_id: nil,
      reason: nil,
      updated_by: nil,
      user_role: nil
    }

    def job_history_fixture(attrs \\ %{}) do
      {:ok, job_history} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Jobs.create_job_history()

      job_history
    end

    test "list_job_history/0 returns all job_history" do
      job_history = job_history_fixture()
      assert Jobs.list_job_history() == [job_history]
    end

    test "get_job_history!/1 returns the job_history with given id" do
      job_history = job_history_fixture()
      assert Jobs.get_job_history!(job_history.id) == job_history
    end

    test "create_job_history/1 with valid data creates a job_history" do
      assert {:ok, %JobHistory{} = job_history} = Jobs.create_job_history(@valid_attrs)
      assert job_history.inserted_by == 42
      assert job_history.invoice_id == 42
      assert job_history.payment_id == 42
      assert job_history.reason == "some reason"
      assert job_history.updated_by == 42
      assert job_history.user_role == "some user_role"
    end

    test "create_job_history/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job_history(@invalid_attrs)
    end

    test "update_job_history/2 with valid data updates the job_history" do
      job_history = job_history_fixture()

      assert {:ok, %JobHistory{} = job_history} =
               Jobs.update_job_history(job_history, @update_attrs)

      assert job_history.inserted_by == 43
      assert job_history.invoice_id == 43
      assert job_history.payment_id == 43
      assert job_history.reason == "some updated reason"
      assert job_history.updated_by == 43
      assert job_history.user_role == "some updated user_role"
    end

    test "update_job_history/2 with invalid data returns error changeset" do
      job_history = job_history_fixture()
      assert {:error, %Ecto.Changeset{}} = Jobs.update_job_history(job_history, @invalid_attrs)
      assert job_history == Jobs.get_job_history!(job_history.id)
    end

    test "delete_job_history/1 deletes the job_history" do
      job_history = job_history_fixture()
      assert {:ok, %JobHistory{}} = Jobs.delete_job_history(job_history)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_job_history!(job_history.id) end
    end

    test "change_job_history/1 returns a job_history changeset" do
      job_history = job_history_fixture()
      assert %Ecto.Changeset{} = Jobs.change_job_history(job_history)
    end
  end

  describe "job_requests" do
    alias Core.Schemas.JobRequest

    @valid_attrs %{title: "some title"}
    @update_attrs %{title: "some updated title"}
    @invalid_attrs %{title: nil}

    def job_request_fixture(attrs \\ %{}) do
      {:ok, job_request} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Jobs.create_job_request()

      job_request
    end

    test "list_job_requests/0 returns all job_requests" do
      job_request = job_request_fixture()
      assert Jobs.list_job_requests() == [job_request]
    end

    test "get_job_request!/1 returns the job_request with given id" do
      job_request = job_request_fixture()
      assert Jobs.get_job_request!(job_request.id) == job_request
    end

    test "create_job_request/1 with valid data creates a job_request" do
      assert {:ok, %JobRequest{} = job_request} = Jobs.create_job_request(@valid_attrs)
      assert job_request.title == "some title"
    end

    test "create_job_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job_request(@invalid_attrs)
    end

    test "update_job_request/2 with valid data updates the job_request" do
      job_request = job_request_fixture()

      assert {:ok, %JobRequest{} = job_request} =
               Jobs.update_job_request(job_request, @update_attrs)

      assert job_request.title == "some updated title"
    end

    test "update_job_request/2 with invalid data returns error changeset" do
      job_request = job_request_fixture()
      assert {:error, %Ecto.Changeset{}} = Jobs.update_job_request(job_request, @invalid_attrs)
      assert job_request == Jobs.get_job_request!(job_request.id)
    end

    test "delete_job_request/1 deletes the job_request" do
      job_request = job_request_fixture()
      assert {:ok, %JobRequest{}} = Jobs.delete_job_request(job_request)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_job_request!(job_request.id) end
    end

    test "change_job_request/1 returns a job_request changeset" do
      job_request = job_request_fixture()
      assert %Ecto.Changeset{} = Jobs.change_job_request(job_request)
    end
  end
end
