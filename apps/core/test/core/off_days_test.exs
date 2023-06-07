defmodule Core.OffDaysTest do
  use Core.DataCase

  alias Core.OffDays

  describe "holidays" do
    alias Core.Schemas.Holiday

    @valid_attrs %{
      description: "some description",
      from: "2010-04-17T14:00:00Z",
      purpose: "some purpose",
      title: "some title",
      to: "2010-04-17T14:00:00Z"
    }
    @update_attrs %{
      description: "some updated description",
      from: "2011-05-18T15:01:01Z",
      purpose: "some updated purpose",
      title: "some updated title",
      to: "2011-05-18T15:01:01Z"
    }
    @invalid_attrs %{description: nil, from: nil, purpose: nil, title: nil, to: nil}

    def holiday_fixture(attrs \\ %{}) do
      {:ok, holiday} =
        attrs
        |> Enum.into(@valid_attrs)
        |> OffDays.create_holiday()

      holiday
    end

    test "list_holidays/0 returns all holidays" do
      holiday = holiday_fixture()
      assert OffDays.list_holidays() == [holiday]
    end

    test "get_holiday!/1 returns the holiday with given id" do
      holiday = holiday_fixture()
      assert OffDays.get_holiday!(holiday.id) == holiday
    end

    test "create_holiday/1 with valid data creates a holiday" do
      assert {:ok, %Holiday{} = holiday} = OffDays.create_holiday(@valid_attrs)
      assert holiday.description == "some description"
      assert holiday.from == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert holiday.purpose == "some purpose"
      assert holiday.title == "some title"
      assert holiday.to == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_holiday/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = OffDays.create_holiday(@invalid_attrs)
    end

    test "update_holiday/2 with valid data updates the holiday" do
      holiday = holiday_fixture()
      assert {:ok, %Holiday{} = holiday} = OffDays.update_holiday(holiday, @update_attrs)
      assert holiday.description == "some updated description"
      assert holiday.from == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert holiday.purpose == "some updated purpose"
      assert holiday.title == "some updated title"
      assert holiday.to == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_holiday/2 with invalid data returns error changeset" do
      holiday = holiday_fixture()
      assert {:error, %Ecto.Changeset{}} = OffDays.update_holiday(holiday, @invalid_attrs)
      assert holiday == OffDays.get_holiday!(holiday.id)
    end

    test "delete_holiday/1 deletes the holiday" do
      holiday = holiday_fixture()
      assert {:ok, %Holiday{}} = OffDays.delete_holiday(holiday)
      assert_raise Ecto.NoResultsError, fn -> OffDays.get_holiday!(holiday.id) end
    end

    test "change_holiday/1 returns a holiday changeset" do
      holiday = holiday_fixture()
      assert %Ecto.Changeset{} = OffDays.change_holiday(holiday)
    end
  end
end
