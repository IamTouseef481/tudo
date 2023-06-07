defmodule Core.Repo.Migrations.AlterDataTypeOfBranchServiceId do
  use Ecto.Migration

  def change do
    execute """
      CREATE OR REPLACE FUNCTION jsonb_to_arr_of_int(_js jsonb)
      RETURNS int[] LANGUAGE sql IMMUTABLE PARALLEL SAFE AS
    ' SELECT ARRAY(SELECT jsonb_array_elements_text(_js)::int)';
    """

    execute """
      ALTER TABLE jobs
      ALTER COLUMN branch_service_ids TYPE int[] USING jsonb_to_arr_of_int(branch_service_ids),
      ALTER COLUMN branch_service_ids set DEFAULT null;
    """
  end
end
