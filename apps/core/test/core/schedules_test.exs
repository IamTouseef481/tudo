defmodule Core.SchedulesTest do
  use Core.DataCase

  alias Core.Schedules

  describe "user_schedules" do
    alias Core.Schemas.UserSchedule

    @valid_attrs %{schedule: %{}}
    @update_attrs %{schedule: %{}}
    @invalid_attrs %{schedule: nil}

    def user_schedule_fixture(attrs \\ %{}) do
      {:ok, user_schedule} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Schedules.create_user_schedule()

      user_schedule
    end

    test "list_user_schedules/0 returns all user_schedules" do
      user_schedule = user_schedule_fixture()
      assert Schedules.list_user_schedules() == [user_schedule]
    end

    test "get_user_schedule!/1 returns the user_schedule with given id" do
      user_schedule = user_schedule_fixture()
      assert Schedules.get_user_schedule!(user_schedule.id) == user_schedule
    end

    test "create_user_schedule/1 with valid data creates a user_schedule" do
      assert {:ok, %UserSchedule{} = user_schedule} = Schedules.create_user_schedule(@valid_attrs)
      assert user_schedule.schedule == %{}
    end

    test "create_user_schedule/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Schedules.create_user_schedule(@invalid_attrs)
    end

    test "update_user_schedule/2 with valid data updates the user_schedule" do
      user_schedule = user_schedule_fixture()

      assert {:ok, %UserSchedule{} = user_schedule} =
               Schedules.update_user_schedule(user_schedule, @update_attrs)

      assert user_schedule.schedule == %{}
    end

    test "update_user_schedule/2 with invalid data returns error changeset" do
      user_schedule = user_schedule_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Schedules.update_user_schedule(user_schedule, @invalid_attrs)

      assert user_schedule == Schedules.get_user_schedule!(user_schedule.id)
    end

    test "delete_user_schedule/1 deletes the user_schedule" do
      user_schedule = user_schedule_fixture()
      assert {:ok, %UserSchedule{}} = Schedules.delete_user_schedule(user_schedule)
      assert_raise Ecto.NoResultsError, fn -> Schedules.get_user_schedule!(user_schedule.id) end
    end

    test "change_user_schedule/1 returns a user_schedule changeset" do
      user_schedule = user_schedule_fixture()
      assert %Ecto.Changeset{} = Schedules.change_user_schedule(user_schedule)
    end
  end
end
