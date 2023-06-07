defmodule Core.PromotionsTest do
  use Core.DataCase

  alias Core.Promotions

  describe "promotions" do
    alias Core.Schemas.Promotion

    @valid_attrs %{
      begin_date: "2010-04-17T14:00:00Z",
      description: "some description",
      end_date: "2010-04-17T14:00:00Z",
      photos: %{},
      title: "some title"
    }
    @update_attrs %{
      begin_date: "2011-05-18T15:01:01Z",
      description: "some updated description",
      end_date: "2011-05-18T15:01:01Z",
      photos: %{},
      title: "some updated title"
    }
    @invalid_attrs %{begin_date: nil, description: nil, end_date: nil, photos: nil, title: nil}

    def promotion_fixture(attrs \\ %{}) do
      {:ok, promotion} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Promotions.create_promotion()

      promotion
    end

    test "list_promotions/0 returns all promotions" do
      promotion = promotion_fixture()
      assert Promotions.list_promotions() == [promotion]
    end

    test "get_promotion!/1 returns the promotion with given id" do
      promotion = promotion_fixture()
      assert Promotions.get_promotion!(promotion.id) == promotion
    end

    test "create_promotion/1 with valid data creates a promotion" do
      assert {:ok, %Promotion{} = promotion} = Promotions.create_promotion(@valid_attrs)
      assert promotion.begin_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert promotion.description == "some description"
      assert promotion.end_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert promotion.photos == %{}
      assert promotion.title == "some title"
    end

    test "create_promotion/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Promotions.create_promotion(@invalid_attrs)
    end

    test "update_promotion/2 with valid data updates the promotion" do
      promotion = promotion_fixture()

      assert {:ok, %Promotion{} = promotion} =
               Promotions.update_promotion(promotion, @update_attrs)

      assert promotion.begin_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert promotion.description == "some updated description"
      assert promotion.end_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert promotion.photos == %{}
      assert promotion.title == "some updated title"
    end

    test "update_promotion/2 with invalid data returns error changeset" do
      promotion = promotion_fixture()
      assert {:error, %Ecto.Changeset{}} = Promotions.update_promotion(promotion, @invalid_attrs)
      assert promotion == Promotions.get_promotion!(promotion.id)
    end

    test "delete_promotion/1 deletes the promotion" do
      promotion = promotion_fixture()
      assert {:ok, %Promotion{}} = Promotions.delete_promotion(promotion)
      assert_raise Ecto.NoResultsError, fn -> Promotions.get_promotion!(promotion.id) end
    end

    test "change_promotion/1 returns a promotion changeset" do
      promotion = promotion_fixture()
      assert %Ecto.Changeset{} = Promotions.change_promotion(promotion)
    end
  end

  describe "promotion_statuses" do
    alias Core.Schemas.PromotionStatuses

    @valid_attrs %{description: "some description", slug: "some slug", title: "some title"}
    @update_attrs %{
      description: "some updated description",
      slug: "some updated slug",
      title: "some updated title"
    }
    @invalid_attrs %{description: nil, slug: nil, title: nil}

    def promotion_statuses_fixture(attrs \\ %{}) do
      {:ok, promotion_statuses} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Promotions.create_promotion_statuses()

      promotion_statuses
    end

    test "list_promotion_statuses/0 returns all promotion_statuses" do
      promotion_statuses = promotion_statuses_fixture()
      assert Promotions.list_promotion_statuses() == [promotion_statuses]
    end

    test "get_promotion_statuses!/1 returns the promotion_statuses with given id" do
      promotion_statuses = promotion_statuses_fixture()
      assert Promotions.get_promotion_statuses!(promotion_statuses.id) == promotion_statuses
    end

    test "create_promotion_statuses/1 with valid data creates a promotion_statuses" do
      assert {:ok, %PromotionStatuses{} = promotion_statuses} =
               Promotions.create_promotion_statuses(@valid_attrs)

      assert promotion_statuses.description == "some description"
      assert promotion_statuses.slug == "some slug"
      assert promotion_statuses.title == "some title"
    end

    test "create_promotion_statuses/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Promotions.create_promotion_statuses(@invalid_attrs)
    end

    test "update_promotion_statuses/2 with valid data updates the promotion_statuses" do
      promotion_statuses = promotion_statuses_fixture()

      assert {:ok, %PromotionStatuses{} = promotion_statuses} =
               Promotions.update_promotion_statuses(promotion_statuses, @update_attrs)

      assert promotion_statuses.description == "some updated description"
      assert promotion_statuses.slug == "some updated slug"
      assert promotion_statuses.title == "some updated title"
    end

    test "update_promotion_statuses/2 with invalid data returns error changeset" do
      promotion_statuses = promotion_statuses_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Promotions.update_promotion_statuses(promotion_statuses, @invalid_attrs)

      assert promotion_statuses == Promotions.get_promotion_statuses!(promotion_statuses.id)
    end

    test "delete_promotion_statuses/1 deletes the promotion_statuses" do
      promotion_statuses = promotion_statuses_fixture()

      assert {:ok, %PromotionStatuses{}} =
               Promotions.delete_promotion_statuses(promotion_statuses)

      assert_raise Ecto.NoResultsError, fn ->
        Promotions.get_promotion_statuses!(promotion_statuses.id)
      end
    end

    test "change_promotion_statuses/1 returns a promotion_statuses changeset" do
      promotion_statuses = promotion_statuses_fixture()
      assert %Ecto.Changeset{} = Promotions.change_promotion_statuses(promotion_statuses)
    end
  end

  describe "deals" do
    alias Core.Schemas.Deal

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def deal_fixture(attrs \\ %{}) do
      {:ok, deal} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Promotions.create_deal()

      deal
    end

    test "list_deals/0 returns all deals" do
      deal = deal_fixture()
      assert Promotions.list_deals() == [deal]
    end

    test "get_deal!/1 returns the deal with given id" do
      deal = deal_fixture()
      assert Promotions.get_deal!(deal.id) == deal
    end

    test "create_deal/1 with valid data creates a deal" do
      assert {:ok, %Deal{} = deal} = Promotions.create_deal(@valid_attrs)
    end

    test "create_deal/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Promotions.create_deal(@invalid_attrs)
    end

    test "update_deal/2 with valid data updates the deal" do
      deal = deal_fixture()
      assert {:ok, %Deal{} = deal} = Promotions.update_deal(deal, @update_attrs)
    end

    test "update_deal/2 with invalid data returns error changeset" do
      deal = deal_fixture()
      assert {:error, %Ecto.Changeset{}} = Promotions.update_deal(deal, @invalid_attrs)
      assert deal == Promotions.get_deal!(deal.id)
    end

    test "delete_deal/1 deletes the deal" do
      deal = deal_fixture()
      assert {:ok, %Deal{}} = Promotions.delete_deal(deal)
      assert_raise Ecto.NoResultsError, fn -> Promotions.get_deal!(deal.id) end
    end

    test "change_deal/1 returns a deal changeset" do
      deal = deal_fixture()
      assert %Ecto.Changeset{} = Promotions.change_deal(deal)
    end
  end
end
