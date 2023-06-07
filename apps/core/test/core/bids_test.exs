defmodule Core.BidsTest do
  use Core.DataCase

  alias Core.Bids

  describe "bids" do
    alias Core.Bids.Bid

    @valid_attrs %{
      arrive_at: ~N[2010-04-17 14:00:00],
      cmr_id: 42,
      country_service_id: 42,
      description: "some description",
      expected_work_duration: ~T[14:00:00],
      gallery: [],
      location_dest: "some location_dest",
      posted_at: ~N[2010-04-17 14:00:00],
      questions: [],
      title: "some title"
    }
    @update_attrs %{
      arrive_at: ~N[2011-05-18 15:01:01],
      cmr_id: 43,
      country_service_id: 43,
      description: "some updated description",
      expected_work_duration: ~T[15:01:01],
      gallery: [],
      location_dest: "some updated location_dest",
      posted_at: ~N[2011-05-18 15:01:01],
      questions: [],
      title: "some updated title"
    }
    @invalid_attrs %{
      arrive_at: nil,
      cmr_id: nil,
      country_service_id: nil,
      description: nil,
      expected_work_duration: nil,
      gallery: nil,
      location_dest: nil,
      posted_at: nil,
      questions: nil,
      title: nil
    }

    def bid_fixture(attrs \\ %{}) do
      {:ok, bid} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Bids.create_bid()

      bid
    end

    test "list_bids/0 returns all bids" do
      bid = bid_fixture()
      assert Bids.list_bids() == [bid]
    end

    test "get_bid!/1 returns the bid with given id" do
      bid = bid_fixture()
      assert Bids.get_bid!(bid.id) == bid
    end

    test "create_bid/1 with valid data creates a bid" do
      assert {:ok, %Bid{} = bid} = Bids.create_bid(@valid_attrs)
      assert bid.arrive_at == ~N[2010-04-17 14:00:00]
      assert bid.cmr_id == 42
      assert bid.country_service_id == 42
      assert bid.description == "some description"
      assert bid.expected_work_duration == ~T[14:00:00]
      assert bid.gallery == []
      assert bid.location_dest == "some location_dest"
      assert bid.posted_at == ~N[2010-04-17 14:00:00]
      assert bid.questions == []
      assert bid.title == "some title"
    end

    test "create_bid/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bids.create_bid(@invalid_attrs)
    end

    test "update_bid/2 with valid data updates the bid" do
      bid = bid_fixture()
      assert {:ok, %Bid{} = bid} = Bids.update_bid(bid, @update_attrs)
      assert bid.arrive_at == ~N[2011-05-18 15:01:01]
      assert bid.cmr_id == 43
      assert bid.country_service_id == 43
      assert bid.description == "some updated description"
      assert bid.expected_work_duration == ~T[15:01:01]
      assert bid.gallery == []
      assert bid.location_dest == "some updated location_dest"
      assert bid.posted_at == ~N[2011-05-18 15:01:01]
      assert bid.questions == []
      assert bid.title == "some updated title"
    end

    test "update_bid/2 with invalid data returns error changeset" do
      bid = bid_fixture()
      assert {:error, %Ecto.Changeset{}} = Bids.update_bid(bid, @invalid_attrs)
      assert bid == Bids.get_bid!(bid.id)
    end

    test "delete_bid/1 deletes the bid" do
      bid = bid_fixture()
      assert {:ok, %Bid{}} = Bids.delete_bid(bid)
      assert_raise Ecto.NoResultsError, fn -> Bids.get_bid!(bid.id) end
    end

    test "change_bid/1 returns a bid changeset" do
      bid = bid_fixture()
      assert %Ecto.Changeset{} = Bids.change_bid(bid)
    end
  end

  describe "proposals" do
    alias Core.Bids.Proposal

    @valid_attrs %{
      bid_id: 42,
      branch_id: 42,
      cost: 120.5,
      is_hourly_cost: true,
      question_answers: %{},
      remarks: "some remarks",
      user_id: 42
    }
    @update_attrs %{
      bid_id: 43,
      branch_id: 43,
      cost: 456.7,
      is_hourly_cost: false,
      question_answers: %{},
      remarks: "some updated remarks",
      user_id: 43
    }
    @invalid_attrs %{
      bid_id: nil,
      branch_id: nil,
      cost: nil,
      is_hourly_cost: nil,
      question_answers: nil,
      remarks: nil,
      user_id: nil
    }

    def proposal_fixture(attrs \\ %{}) do
      {:ok, proposal} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Bids.create_proposal()

      proposal
    end

    test "list_proposals/0 returns all proposals" do
      proposal = proposal_fixture()
      assert Bids.list_proposals() == [proposal]
    end

    test "get_proposal!/1 returns the proposal with given id" do
      proposal = proposal_fixture()
      assert Bids.get_proposal!(proposal.id) == proposal
    end

    test "create_proposal/1 with valid data creates a proposal" do
      assert {:ok, %Proposal{} = proposal} = Bids.create_proposal(@valid_attrs)
      assert proposal.bid_id == 42
      assert proposal.branch_id == 42
      assert proposal.cost == 120.5
      assert proposal.is_hourly_cost == true
      assert proposal.question_answers == %{}
      assert proposal.remarks == "some remarks"
      assert proposal.user_id == 42
    end

    test "create_proposal/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bids.create_proposal(@invalid_attrs)
    end

    test "update_proposal/2 with valid data updates the proposal" do
      proposal = proposal_fixture()
      assert {:ok, %Proposal{} = proposal} = Bids.update_proposal(proposal, @update_attrs)
      assert proposal.bid_id == 43
      assert proposal.branch_id == 43
      assert proposal.cost == 456.7
      assert proposal.is_hourly_cost == false
      assert proposal.question_answers == %{}
      assert proposal.remarks == "some updated remarks"
      assert proposal.user_id == 43
    end

    test "update_proposal/2 with invalid data returns error changeset" do
      proposal = proposal_fixture()
      assert {:error, %Ecto.Changeset{}} = Bids.update_proposal(proposal, @invalid_attrs)
      assert proposal == Bids.get_proposal!(proposal.id)
    end

    test "delete_proposal/1 deletes the proposal" do
      proposal = proposal_fixture()
      assert {:ok, %Proposal{}} = Bids.delete_proposal(proposal)
      assert_raise Ecto.NoResultsError, fn -> Bids.get_proposal!(proposal.id) end
    end

    test "change_proposal/1 returns a proposal changeset" do
      proposal = proposal_fixture()
      assert %Ecto.Changeset{} = Bids.change_proposal(proposal)
    end
  end
end
