defmodule Core.Repo.Migrations.CreateTriggerOnInvoicesIncrementInvoiceIdByYear do
  @moduledoc false
  use Ecto.Migration

  def up do
    execute("""
      DROP TRIGGER IF EXISTS increment_by_year_in_invoice_id on invoices;
    """)

    execute("""
    CREATE OR REPLACE FUNCTION increment_by_year_in_invoice_id()
    RETURNS TRIGGER
    LANGUAGE plpgsql AS $$
    BEGIN
    NEW.invoice_id = (select (count(id)+1) from invoices where extract(year from inserted_at) = extract(year from now()));
    RETURN NEW;
    END;
    $$;
    """)

    execute("""
    CREATE TRIGGER increment_by_year_in_invoice_id BEFORE INSERT ON invoices
      FOR EACH ROW EXECUTE PROCEDURE increment_by_year_in_invoice_id();
    """)
  end

  def down do
    execute("""
      DROP TRIGGER IF EXISTS increment_by_year_in_invoice_id on invoices;
    """)

    execute("""
    DROP FUNCTION IF EXISTS increment_by_year_in_invoice_id();
    """)
  end
end
