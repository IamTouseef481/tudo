defmodule TudoChatWeb.Controllers.FileController do
  @moduledoc false
  use TudoChatWeb, :controller
  alias TudoChatWeb.Upload.FileUploader
  alias TudoChatWeb.Upload.MessageFileUploader

  # upload chat message images and files
  def upload_message_files(params) do
    storage = "Messages"

    case file_size_verification(params) do
      {:error, error} ->
        {:error, error}

      files ->
        Enum.map(files, fn file ->
          file = make_unique_name(file)

          case MessageFileUploader.store({file, %{storage: storage}}) do
            {:ok, name} ->
              path = MessageFileUploader.storage_dir(2, {file, %{storage: storage}})
              bucket = Application.get_env(:core, :ex_aws)[:bucket]
              url = Application.get_env(:core, :ex_aws)[:url]

              %{
                original: "#{url}#{bucket}/#{path}#{name}"
              }

            {:error, :invalid_file} ->
              %{error: ["Invalid file format, upload blocked!"]}

            _ ->
              %{error: ["Something went wrong, file upload failed"]}
          end
        end)
        |> Enum.reject(fn file -> Map.has_key?(file, :error) == true end)
    end
  end

  def file_size_verification(files) do
    Enum.reduce_while(files, [], fn file, acc ->
      case File.stat!(file.path) do
        %{size: file_size} ->
          file_size = file_size / (1000 * 1000)

          if file_size < 100 do
            {:cont, [file | acc]}
          else
            {:halt, {:error, ["#{file.filename} File size should less than 100 MB"]}}
          end

        _ ->
          {:halt, {:error, ["unable to get size of #{file.filename}"]}}
      end
    end)
  rescue
    exception ->
      logger(__MODULE__, exception, ["error in fetching file size!"], __ENV__.line)
  end

  def get_message_files(files) do
    Enum.map(files, fn file ->
      %{path: path, name: name} = file

      with {:ok, image} <- fetch_message_file("#{path}#{name}") do
        image
      end
    end)
  end

  def fetch_message_file(message) do
    {:ok, url} =
      ExAws.Config.new(:s3)
      |> ExAws.S3.presigned_url(
        :get,
        Application.get_env(:tudo_chat, :ex_aws)[:message_bucket],
        message,
        expires_in: Application.get_env(:tudo_chat, :ex_aws)[:expires_in]
        #        [acl: "public_read",
        #        virtual_host: true
        #        expires_in: Application.get_env(:tudo_chat, :ex_aws)[:icon_expires_in]
        #        ]
      )

    #    %HTTPoison.Response{body: body} = HTTPoison.get!( url )
    #    mime_type=MIME.type(List.last(path))
    #    if mime_type =~ "image" ||mime_type =~ "video" ||mime_type =~ "audio"   do
    #      {:ok, %{url: url, binary: body}}
    {:ok, %{url: url}}
    #    else
    ##      send_download(conn, {:binary, body}, filename: List.last(path))
    #    end
  end

  def delete_message_files(params) do
    Enum.map(
      params,
      fn %{"name" => name, "path" => path} ->
        bucket = Application.get_env(:tudo_chat, :ex_aws)[:message_bucket]
        message_file = bucket <> "/" <> path <> name

        ExAws.S3.delete_object(bucket, message_file)
        |> ExAws.request!()

        #        {:ok, filename} = FileUploader.store(Application.get_env(:tudo_chat, :ex_aws)[:message_bucket]<> "/" <> path <> name)
        #        :ok = FileUploader.delete(filename)
      end
    )
  end

  def make_unique_name(file, current_datetime \\ DateTime.utc_now()) do
    file_name =
      to_string(DateTime.to_unix(current_datetime, :microsecond)) <> "_" <> file.filename

    Map.merge(file, %{filename: file_name})
  end

  def upload(params, storage) do
    case file_size_verification(params) do
      {:error, error} ->
        {:error, error}

      files ->
        Enum.map(files, fn file ->
          file = make_unique_name(file)

          case FileUploader.store({file, %{storage: storage}}) do
            {:ok, name} ->
              path = FileUploader.storage_dir(1, {file, %{storage: storage}})
              bucket = Application.get_env(:core, :ex_aws)[:bucket]
              url = Application.get_env(:core, :ex_aws)[:url]

              %{
                original: "#{url}#{bucket}/#{path}original/#{name}",
                thumb: "#{url}#{bucket}/#{path}thumb/#{name}"
              }

            {:error, :invalid_file} ->
              %{error: ["Invalid file format, upload blocked!"]}

            _ ->
              %{error: ["Something went wrong, file upload failed"]}
          end
        end)
        |> Enum.reject(fn file -> Map.has_key?(file, :error) == true end)
    end
  end

  def get_files(%{"path" => %{"thumb" => thumb, "original" => original}, "name" => name}) do
    get_files(thumb, original, name)
  end

  def get_files(%{path: %{thumb: thumb, original: original}, name: name}) do
    get_files(thumb, original, name)
  end

  def get_files(thumb, original, name) do
    with {:ok, thumb} <- fetch_file("#{thumb}#{name}"),
         {:ok, original} <- fetch_file("#{original}#{name}") do
      %{thumb: thumb, original: original}
    else
      _ ->
        %{thumb: nil, original: nil}
    end
  end

  def fetch_file(path) do
    {:ok, url} =
      ExAws.Config.new(:s3)
      |> ExAws.S3.presigned_url(
        :get,
        Application.get_env(:tudo_chat, :ex_aws)[:bucket],
        path,
        expires_in: Application.get_env(:tudo_chat, :ex_aws)[:expires_in]
      )

    #    %HTTPoison.Response{body: body} = HTTPoison.get!( url )
    #    mime_type=MIME.type(List.last(path))
    #    if mime_type =~ "image" ||mime_type =~ "video" ||mime_type =~ "audio"   do
    #      {:ok, %{url: url, binary: body}}
    {:ok, %{url: url}}
    #    else
    ##      send_download(conn, {:binary, body}, filename: List.last(path))
    #    end
  end

  def delete(params) do
    Enum.map(
      params,
      fn %{"name" => name, "path" => %{"original" => original, "thumb" => thumb}} ->
        {:ok, original_filename} =
          FileUploader.store(
            Application.get_env(:tudo_chat, :ex_aws)[:bucket] <> "/" <> original <> name
          )

        :ok = FileUploader.delete(original_filename)

        {:ok, original_filename} =
          FileUploader.store(
            Application.get_env(:tudo_chat, :ex_aws)[:bucket] <> "/" <> thumb <> name
          )

        :ok = FileUploader.delete(original_filename)
      end
    )
  end
end
