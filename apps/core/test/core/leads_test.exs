defmodule Core.LeadsTest do
  use Core.DataCase

  alias Core.Leads

  describe "leads" do
    alias Core.Schemas.Lead

    @valid_attrs %{
      arrive_at: "2010-04-17T14:00:00Z",
      is_flexible: true,
      location: %{},
      rating: 120.5
    }
    @update_attrs %{
      arrive_at: "2011-05-18T15:01:01Z",
      is_flexible: false,
      location: %{},
      rating: 456.7
    }
    @invalid_attrs %{arrive_at: nil, is_flexible: nil, location: nil, rating: nil}

    def lead_fixture(attrs \\ %{}) do
      {:ok, lead} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Leads.create_lead()

      lead
    end

    test "list_leads/0 returns all leads" do
      lead = lead_fixture()
      assert Leads.list_leads() == [lead]
    end

    test "get_lead!/1 returns the lead with given id" do
      lead = lead_fixture()
      assert Leads.get_lead!(lead.id) == lead
    end

    test "create_lead/1 with valid data creates a lead" do
      assert {:ok, %Lead{} = lead} = Leads.create_lead(@valid_attrs)
      assert lead.arrive_at == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert lead.is_flexible == true
      assert lead.location == %{}
      assert lead.rating == 120.5
    end

    test "create_lead/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Leads.create_lead(@invalid_attrs)
    end

    test "update_lead/2 with valid data updates the lead" do
      lead = lead_fixture()
      assert {:ok, %Lead{} = lead} = Leads.update_lead(lead, @update_attrs)
      assert lead.arrive_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert lead.is_flexible == false
      assert lead.location == %{}
      assert lead.rating == 456.7
    end

    test "update_lead/2 with invalid data returns error changeset" do
      lead = lead_fixture()
      assert {:error, %Ecto.Changeset{}} = Leads.update_lead(lead, @invalid_attrs)
      assert lead == Leads.get_lead!(lead.id)
    end

    test "delete_lead/1 deletes the lead" do
      lead = lead_fixture()
      assert {:ok, %Lead{}} = Leads.delete_lead(lead)
      assert_raise Ecto.NoResultsError, fn -> Leads.get_lead!(lead.id) end
    end

    test "change_lead/1 returns a lead changeset" do
      lead = lead_fixture()
      assert %Ecto.Changeset{} = Leads.change_lead(lead)
    end
  end
end
