defmodule Core.CashPaymentsTest do
  use Core.DataCase

  alias Core.CashPayments

  describe "cash_payments" do
    alias Core.Schemas.CashPayment

    @valid_attrs %{
      adjust: true,
      adjust_reason: "some adjust_reason",
      paid_amount: 120.5,
      pay_due_amount: 120.5,
      returned_amount: 120.5
    }
    @update_attrs %{
      adjust: false,
      adjust_reason: "some updated adjust_reason",
      paid_amount: 456.7,
      pay_due_amount: 456.7,
      returned_amount: 456.7
    }
    @invalid_attrs %{
      adjust: nil,
      adjust_reason: nil,
      paid_amount: nil,
      pay_due_amount: nil,
      returned_amount: nil
    }

    def cash_payment_fixture(attrs \\ %{}) do
      {:ok, cash_payment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> CashPayments.create_cash_payment()

      cash_payment
    end

    test "list_cash_payments/0 returns all cash_payments" do
      cash_payment = cash_payment_fixture()
      assert CashPayments.list_cash_payments() == [cash_payment]
    end

    test "get_cash_payment!/1 returns the cash_payment with given id" do
      cash_payment = cash_payment_fixture()
      assert CashPayments.get_cash_payment!(cash_payment.id) == cash_payment
    end

    test "create_cash_payment/1 with valid data creates a cash_payment" do
      assert {:ok, %CashPayment{} = cash_payment} = CashPayments.create_cash_payment(@valid_attrs)
      assert cash_payment.adjust == true
      assert cash_payment.adjust_reason == "some adjust_reason"
      assert cash_payment.paid_amount == 120.5
      assert cash_payment.pay_due_amount == 120.5
      assert cash_payment.returned_amount == 120.5
    end

    test "create_cash_payment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CashPayments.create_cash_payment(@invalid_attrs)
    end

    test "update_cash_payment/2 with valid data updates the cash_payment" do
      cash_payment = cash_payment_fixture()

      assert {:ok, %CashPayment{} = cash_payment} =
               CashPayments.update_cash_payment(cash_payment, @update_attrs)

      assert cash_payment.adjust == false
      assert cash_payment.adjust_reason == "some updated adjust_reason"
      assert cash_payment.paid_amount == 456.7
      assert cash_payment.pay_due_amount == 456.7
      assert cash_payment.returned_amount == 456.7
    end

    test "update_cash_payment/2 with invalid data returns error changeset" do
      cash_payment = cash_payment_fixture()

      assert {:error, %Ecto.Changeset{}} =
               CashPayments.update_cash_payment(cash_payment, @invalid_attrs)

      assert cash_payment == CashPayments.get_cash_payment!(cash_payment.id)
    end

    test "delete_cash_payment/1 deletes the cash_payment" do
      cash_payment = cash_payment_fixture()
      assert {:ok, %CashPayment{}} = CashPayments.delete_cash_payment(cash_payment)
      assert_raise Ecto.NoResultsError, fn -> CashPayments.get_cash_payment!(cash_payment.id) end
    end

    test "change_cash_payment/1 returns a cash_payment changeset" do
      cash_payment = cash_payment_fixture()
      assert %Ecto.Changeset{} = CashPayments.change_cash_payment(cash_payment)
    end
  end

  describe "cheque_payments" do
    alias Core.Schemas.ChequePayment

    @valid_attrs %{
      adjust: true,
      adjust_reason: "some adjust_reason",
      bank_name: "some bank_name",
      cheque_amount: 120.5,
      cheque_image: %{},
      cheque_number: 42,
      date: ~D[2010-04-17],
      in_favor_of_name: "some in_favor_of_name",
      pay_due_amount: 120.5,
      signatory_name: "some signatory_name"
    }
    @update_attrs %{
      adjust: false,
      adjust_reason: "some updated adjust_reason",
      bank_name: "some updated bank_name",
      cheque_amount: 456.7,
      cheque_image: %{},
      cheque_number: 43,
      date: ~D[2011-05-18],
      in_favor_of_name: "some updated in_favor_of_name",
      pay_due_amount: 456.7,
      signatory_name: "some updated signatory_name"
    }
    @invalid_attrs %{
      adjust: nil,
      adjust_reason: nil,
      bank_name: nil,
      cheque_amount: nil,
      cheque_image: nil,
      cheque_number: nil,
      date: nil,
      in_favor_of_name: nil,
      pay_due_amount: nil,
      signatory_name: nil
    }

    def cheque_payment_fixture(attrs \\ %{}) do
      {:ok, cheque_payment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> CashPayments.create_cheque_payment()

      cheque_payment
    end

    test "list_cheque_payments/0 returns all cheque_payments" do
      cheque_payment = cheque_payment_fixture()
      assert CashPayments.list_cheque_payments() == [cheque_payment]
    end

    test "get_cheque_payment!/1 returns the cheque_payment with given id" do
      cheque_payment = cheque_payment_fixture()
      assert CashPayments.get_cheque_payment!(cheque_payment.id) == cheque_payment
    end

    test "create_cheque_payment/1 with valid data creates a cheque_payment" do
      assert {:ok, %ChequePayment{} = cheque_payment} =
               CashPayments.create_cheque_payment(@valid_attrs)

      assert cheque_payment.adjust == true
      assert cheque_payment.adjust_reason == "some adjust_reason"
      assert cheque_payment.bank_name == "some bank_name"
      assert cheque_payment.cheque_amount == 120.5
      assert cheque_payment.cheque_image == %{}
      assert cheque_payment.cheque_number == 42
      assert cheque_payment.date == ~D[2010-04-17]
      assert cheque_payment.in_favor_of_name == "some in_favor_of_name"
      assert cheque_payment.pay_due_amount == 120.5
      assert cheque_payment.signatory_name == "some signatory_name"
    end

    test "create_cheque_payment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CashPayments.create_cheque_payment(@invalid_attrs)
    end

    test "update_cheque_payment/2 with valid data updates the cheque_payment" do
      cheque_payment = cheque_payment_fixture()

      assert {:ok, %ChequePayment{} = cheque_payment} =
               CashPayments.update_cheque_payment(cheque_payment, @update_attrs)

      assert cheque_payment.adjust == false
      assert cheque_payment.adjust_reason == "some updated adjust_reason"
      assert cheque_payment.bank_name == "some updated bank_name"
      assert cheque_payment.cheque_amount == 456.7
      assert cheque_payment.cheque_image == %{}
      assert cheque_payment.cheque_number == 43
      assert cheque_payment.date == ~D[2011-05-18]
      assert cheque_payment.in_favor_of_name == "some updated in_favor_of_name"
      assert cheque_payment.pay_due_amount == 456.7
      assert cheque_payment.signatory_name == "some updated signatory_name"
    end

    test "update_cheque_payment/2 with invalid data returns error changeset" do
      cheque_payment = cheque_payment_fixture()

      assert {:error, %Ecto.Changeset{}} =
               CashPayments.update_cheque_payment(cheque_payment, @invalid_attrs)

      assert cheque_payment == CashPayments.get_cheque_payment!(cheque_payment.id)
    end

    test "delete_cheque_payment/1 deletes the cheque_payment" do
      cheque_payment = cheque_payment_fixture()
      assert {:ok, %ChequePayment{}} = CashPayments.delete_cheque_payment(cheque_payment)

      assert_raise Ecto.NoResultsError, fn ->
        CashPayments.get_cheque_payment!(cheque_payment.id)
      end
    end

    test "change_cheque_payment/1 returns a cheque_payment changeset" do
      cheque_payment = cheque_payment_fixture()
      assert %Ecto.Changeset{} = CashPayments.change_cheque_payment(cheque_payment)
    end
  end
end
