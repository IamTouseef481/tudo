defmodule Core.InvoicesTest do
  use Core.DataCase

  alias Core.Invoices

  describe "invoices" do
    alias Core.Schemas.Invoice

    @valid_attrs %{change: true, comment: "some comment", details: %{}, job_id: 42}
    @update_attrs %{change: false, comment: "some updated comment", details: %{}, job_id: 43}
    @invalid_attrs %{change: nil, comment: nil, details: nil, job_id: nil}

    def invoice_fixture(attrs \\ %{}) do
      {:ok, invoice} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Invoices.create_invoice()

      invoice
    end

    test "list_invoices/0 returns all invoices" do
      invoice = invoice_fixture()
      assert Invoices.list_invoices() == [invoice]
    end

    test "get_invoice!/1 returns the invoice with given id" do
      invoice = invoice_fixture()
      assert Invoices.get_invoice!(invoice.id) == invoice
    end

    test "create_invoice/1 with valid data creates a invoice" do
      assert {:ok, %Invoice{} = invoice} = Invoices.create_invoice(@valid_attrs)
      assert invoice.change == true
      assert invoice.comment == "some comment"
      assert invoice.details == %{}
      assert invoice.job_id == 42
    end

    test "create_invoice/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Invoices.create_invoice(@invalid_attrs)
    end

    test "update_invoice/2 with valid data updates the invoice" do
      invoice = invoice_fixture()
      assert {:ok, %Invoice{} = invoice} = Invoices.update_invoice(invoice, @update_attrs)
      assert invoice.change == false
      assert invoice.comment == "some updated comment"
      assert invoice.details == %{}
      assert invoice.job_id == 43
    end

    test "update_invoice/2 with invalid data returns error changeset" do
      invoice = invoice_fixture()
      assert {:error, %Ecto.Changeset{}} = Invoices.update_invoice(invoice, @invalid_attrs)
      assert invoice == Invoices.get_invoice!(invoice.id)
    end

    test "delete_invoice/1 deletes the invoice" do
      invoice = invoice_fixture()
      assert {:ok, %Invoice{}} = Invoices.delete_invoice(invoice)
      assert_raise Ecto.NoResultsError, fn -> Invoices.get_invoice!(invoice.id) end
    end

    test "change_invoice/1 returns a invoice changeset" do
      invoice = invoice_fixture()
      assert %Ecto.Changeset{} = Invoices.change_invoice(invoice)
    end
  end

  describe "invoice_history" do
    alias Core.Schemas.InvoiceHistory

    @valid_attrs %{
      amount: %{},
      change: true,
      comment: "some comment",
      discounts: [],
      invoice_id: 42,
      taxes: []
    }
    @update_attrs %{
      amount: %{},
      change: false,
      comment: "some updated comment",
      discounts: [],
      invoice_id: 43,
      taxes: []
    }
    @invalid_attrs %{
      amount: nil,
      change: nil,
      comment: nil,
      discounts: nil,
      invoice_id: nil,
      taxes: nil
    }

    def invoice_history_fixture(attrs \\ %{}) do
      {:ok, invoice_history} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Invoices.create_invoice_history()

      invoice_history
    end

    test "list_invoice_history/0 returns all invoice_history" do
      invoice_history = invoice_history_fixture()
      assert Invoices.list_invoice_history() == [invoice_history]
    end

    test "get_invoice_history!/1 returns the invoice_history with given id" do
      invoice_history = invoice_history_fixture()
      assert Invoices.get_invoice_history!(invoice_history.id) == invoice_history
    end

    test "create_invoice_history/1 with valid data creates a invoice_history" do
      assert {:ok, %InvoiceHistory{} = invoice_history} =
               Invoices.create_invoice_history(@valid_attrs)

      assert invoice_history.amount == %{}
      assert invoice_history.change == true
      assert invoice_history.comment == "some comment"
      assert invoice_history.discounts == []
      assert invoice_history.invoice_id == 42
      assert invoice_history.taxes == []
    end

    test "create_invoice_history/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Invoices.create_invoice_history(@invalid_attrs)
    end

    test "update_invoice_history/2 with valid data updates the invoice_history" do
      invoice_history = invoice_history_fixture()

      assert {:ok, %InvoiceHistory{} = invoice_history} =
               Invoices.update_invoice_history(invoice_history, @update_attrs)

      assert invoice_history.amount == %{}
      assert invoice_history.change == false
      assert invoice_history.comment == "some updated comment"
      assert invoice_history.discounts == []
      assert invoice_history.invoice_id == 43
      assert invoice_history.taxes == []
    end

    test "update_invoice_history/2 with invalid data returns error changeset" do
      invoice_history = invoice_history_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Invoices.update_invoice_history(invoice_history, @invalid_attrs)

      assert invoice_history == Invoices.get_invoice_history!(invoice_history.id)
    end

    test "delete_invoice_history/1 deletes the invoice_history" do
      invoice_history = invoice_history_fixture()
      assert {:ok, %InvoiceHistory{}} = Invoices.delete_invoice_history(invoice_history)

      assert_raise Ecto.NoResultsError, fn ->
        Invoices.get_invoice_history!(invoice_history.id)
      end
    end

    test "change_invoice_history/1 returns a invoice_history changeset" do
      invoice_history = invoice_history_fixture()
      assert %Ecto.Changeset{} = Invoices.change_invoice_history(invoice_history)
    end
  end
end
