defmodule CoreWeb.Controllers.RestFileController do
  @moduledoc false

  use CoreWeb, :controller

  @uploads "./priv/static/uploads/"

  def upload(conn, %{"file" => files}) do
    case CoreWeb.Controllers.ImageController.upload(files, "services") do
      {:error, error} ->
        conn
        |> put_view(CoreWeb.Views.FileView)
        |> render("file.json", %{error: error})

      files ->
        conn
        |> put_view(CoreWeb.Views.FileView)
        |> render("files.json", %{files: files})
    end
  end

  def upload(conn, %{"file" => file, "for_entity" => for_entity} = body) do
    if file && Map.has_key?(file, :path) && File.exists?(file.path) do
      #      mime = file.content_type

      {_folder_id, body} = Map.pop(body, "folder_id")
      {_app, body} = Map.pop(body, "app")
      {_title, _} = Map.pop(body, "title", file.filename)
      #      title = if title == "null", do: nil, else: title
      #      folder_id = if folder_id == "null", do: nil, else: folder_id
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

      #      create(conn, %{
      #        @singular => %{
      #          "mime" => mime,
      #          "title" => title,
      #          "slug" => entity_path <> date_path <> slug,
      #          "folder_id" => folder_id
      #        }
      #      })
    else
      conn
      |> send_resp(400, "File missing or error occured while uploading.")
    end
  end

  def upload_icons(conn, %{"file" => files}) do
    case CoreWeb.Controllers.ImageController.upload_icons(files) do
      {:error, error} ->
        conn
        |> put_view(CoreWeb.Views.FileView)
        |> render("file.json", %{error: error})

      files ->
        conn
        |> put_view(CoreWeb.Views.FileView)
        |> render("files.json", %{files: files})
    end
  end

  def remove(conn, %{"files" => files} = _body) do
    case CoreWeb.Controllers.ImageController.delete(files) do
      :ok -> conn |> send_resp(200, "ok") |> Plug.Conn.halt()
      _ -> conn |> send_resp(400, "something went wrong")
    end

    #    case response do
    #      :ok -> conn |>
    #      _ -> conn |> send_resp(400, "File missing or error occured while removing.")
    #    end
  end

  #  def remove(conn, body = %{"files" => files}) do
  #    if(files && files != nil )do
  #      Enum.each files, fn file ->
  #        params = %{
  #          "slug" => file
  #        }
  #        delete(conn, params)
  #
  #        {app, _body} = Map.pop(body, "app")
  #        file_path = if app === "admin", do: "./priv/static/app_imgs/", else: @uploads
  #        if(File.exists?(file_path <> file)) do
  #          File.rm(file_path <> file )
  #        end
  #
  #      end
  #      conn |> send_resp(200, "ok") |> Plug.Conn.halt
  #    else
  #      conn
  #      |> send_resp(400, "File missing or error occured while removing.")
  #    end
  #
  #    #    case response do
  #    #      :ok -> conn |>
  #    #      _ -> conn |> send_resp(400, "File missing or error occured while removing.")
  #    #    end
  #
  #  end

  def unique_file_name(ext, upload_path, current_datetime \\ DateTime.utc_now()) do
    file = upload_path <> to_string(DateTime.to_unix(current_datetime, :microsecond)) <> ext

    if File.exists?(file) do
      unique_file_name(ext, upload_path)
    else
      to_string(DateTime.to_unix(current_datetime, :microsecond)) <> ext
    end
  end

  def upload_file(%{"files" => files}) do
    files =
      Enum.map(files, fn file ->
        filename = String.split(file, "/") |> List.last()

        %Plug.Upload{
          content_type: "application/pdf",
          filename: filename,
          path: file
        }
      end)

    case CoreWeb.Controllers.FileController.upload_file(files, "services") do
      {:error, error} -> {:error, error}
      files -> files
    end
  end
end
