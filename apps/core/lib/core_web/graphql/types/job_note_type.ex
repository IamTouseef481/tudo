defmodule CoreWeb.GraphQL.Types.JobNoteType do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: Core.Repo

  # Response Data Objects...

  object :job_note_type do
    field :note, :string
    field :job_id, :integer
    field :user_id, :integer
    field :employee_id, :integer
    field :note_type, :string
    field :inserted_at, :datetime
    field :user, :user_short_object_type
  end

  object :user_short_object_type do
    field :id, :integer
    field :first_name, :string
    field :last_name, :string
    field :profile, :json
  end

  input_object :job_note_input_type do
    field :job_id, non_null(:integer)
    field :note, non_null(:string)
    field :note_type, :note_type
  end

  input_object :show_job_note_input_type do
    field :job_id, :integer
    field :user_id, :integer
    field :branch_id, :integer
  end

  enum :note_type do
    value(:cmr_internal)
    value(:bsp_internal)
    value(:bsp_general)
  end
end
