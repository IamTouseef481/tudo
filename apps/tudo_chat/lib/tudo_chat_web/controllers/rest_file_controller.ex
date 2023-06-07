defmodule TudoChatWeb.Controllers.RestFileController do
  @moduledoc false
  use TudoChatWeb, :controller
  use FFmpex.Options
  alias TudoChatWeb.Controllers.FileController

  @uploads "./priv/static/uploads/"

  def upload_messages(conn, %{"file" => files}) do
    files = check_audio_video_duration(files)

    case FileController.upload_message_files(files) do
      {:error, error} ->
        conn
        |> put_view(TudoChatWeb.Views.FileView)
        |> render("file.json", %{error: error})

      [error: :invalid_file] ->
        conn
        |> put_view(TudoChatWeb.Views.FileView)
        |> render("file.json", %{error: "invalid file format"})

      [error: error] ->
        conn
        |> put_view(TudoChatWeb.Views.FileView)
        |> render("file.json", %{error: error})

      files ->
        conn
        |> put_view(TudoChatWeb.Views.FileView)
        |> render("files.json", %{files: files})
    end
  end

  def check_audio_video_duration(files) do
    Enum.reduce(files, [], fn file, acc ->
      cond do
        String.contains?(file.content_type, "video/") and FFprobe.duration(file.path) < 60 ->
          [file | acc]

        String.contains?(file.content_type, "audio/") and FFprobe.duration(file.path) < 180 ->
          [file | acc]

        String.contains?(file.content_type, "image/") ->
          [file | acc]

        true ->
          acc
      end
    end)
  end

  def remove_message_files(conn, %{"files" => files}) do
    case FileController.delete_message_files(files) do
      :ok -> conn |> send_resp(200, "ok") |> Plug.Conn.halt()
      _ -> conn |> send_resp(400, "something went wrong")
    end
  end

  def unique_file_name(ext, upload_path, current_datetime \\ DateTime.utc_now()) do
    file = upload_path <> to_string(DateTime.to_unix(current_datetime, :microsecond)) <> ext

    if File.exists?(file) do
      unique_file_name(ext, upload_path)
    else
      to_string(DateTime.to_unix(current_datetime, :microsecond)) <> ext
    end
  end

  def upload(conn, %{"file" => files}) do
    case FileController.upload(files, "messages") do
      {:error, error} ->
        conn
        |> put_view(TudoChatWeb.Views.FileView)
        |> render("file.json", %{error: error})

      [error: :invalid_file] ->
        conn
        |> put_view(TudoChatWeb.Views.FileView)
        |> render("file.json", %{error: "invalid file format"})

      [error: error] ->
        conn
        |> put_view(TudoChatWeb.Views.FileView)
        |> render("file.json", %{error: error})

      files ->
        conn
        |> put_view(TudoChatWeb.Views.FileView)
        |> render("files.json", %{files: files})
    end
  end

  def upload(conn, %{"file" => file, "for_entity" => for_entity} = body) do
    if file && Map.has_key?(file, :path) && File.exists?(file.path) do
      _mime = file.content_type

      {folder_id, body} = Map.pop(body, "folder_id")
      {_app, body} = Map.pop(body, "app")
      {title, _} = Map.pop(body, "title", file.filename)
      _title = if title == "null", do: nil, else: title
      _folder_id = if folder_id == "null", do: nil, else: folder_id
      upload_path = @uploads

      current_datetime = DateTime.utc_now()
      current_year = to_string(current_datetime.year)
      current_month = to_string(current_datetime.month)
      current_day = to_string(current_datetime.day)

      date_path = "/" <> current_year <> "/" <> current_month <> "/" <> current_day <> "/"

      entity_path =
        case for_entity do
          "jobs" -> for_entity
          _ -> "users"
        end

      if !File.exists?(upload_path <> entity_path <> date_path) do
        File.mkdir_p(upload_path <> entity_path <> date_path)
      end

      slug =
        unique_file_name(
          Path.extname(file.filename),
          upload_path <> entity_path <> date_path,
          current_datetime
        )

      File.cp(file.path, upload_path <> entity_path <> date_path <> slug)
    else
      conn
      |> send_resp(400, "File missing or error occurred while uploading.")
    end
  end

  def remove(conn, %{"files" => files} = body) do
    if files && files != nil do
      Enum.each(files, fn file ->
        {app, _body} = Map.pop(body, "app")
        file_path = if app === "admin", do: "./priv/static/app_imgs/", else: @uploads

        if File.exists?(file_path <> file) do
          File.rm(file_path <> file)
        end
      end)

      conn |> send_resp(200, "ok") |> Plug.Conn.halt()
    else
      conn
      |> send_resp(400, "File missing or error occurred while removing.")
    end
  end
end
