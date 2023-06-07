defmodule CoreWeb.GraphQL.Resolvers.FileResolver do
  @moduledoc false
  import CoreWeb.Utils.CommonFunctions, only: [convert_files: 1]
  import CoreWeb.Controllers.ImageController, only: [get_icons: 1, upload_icons: 1]

  def get_files(_, %{input: files}, _) do
    {:ok, convert_files(files)}
  end

  def upload_icons(_, %{input: icons}, _) do
    {:ok, upload_icons(icons)}
  end

  def get_icons(_, %{input: icons}, _) do
    {:ok, get_icons(icons)}
  end
end
