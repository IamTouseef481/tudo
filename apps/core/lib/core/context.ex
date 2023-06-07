defmodule Core.Context do
  @moduledoc """
  The Accounts context.
  """

  alias Core.Repo

  def get_by(model, args) do
    Repo.get_by(model, args)
  end

  def create(model, attrs \\ %{}) do
    struct(model)
    |> model.changeset(attrs)
    |> Repo.insert()
  end

  def update(model, data, attrs) do
    data
    |> model.changeset(attrs)
    |> Repo.update()
  end

  def insert_or_update(model, obj, get_by_list) do
    get_by(model, get_by_list)

    case get_by(model, get_by_list) do
      nil -> create(model, obj)
      data -> update(model, data, obj)
    end
  end
end
