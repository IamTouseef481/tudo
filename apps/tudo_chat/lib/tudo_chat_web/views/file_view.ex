defmodule TudoChatWeb.Views.FileView do
  @moduledoc false
  use TudoChatWeb, :view
  alias TudoChatWeb.Views.FileView

  def render("files.json", %{files: files}) do
    %{status: "ok", files: render_many(files, FileView, "file.json")}
  end

  def render("file.json", %{file: file}) do
    file
  end

  def render("file.json", %{error: error}) do
    %{status: "error", error: error}
  end

  def render("file.json", %{file: error}) do
    error
  end
end
