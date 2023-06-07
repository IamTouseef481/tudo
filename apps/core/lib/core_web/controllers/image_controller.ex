defmodule CoreWeb.Controllers.ImageController do
  @moduledoc false

  use CoreWeb, :controller

  alias CoreWeb.Services.ImageUploader
  alias CoreWeb.Services.IconFileUploader

  def create(_conn, _params) do
    #    %Core.Files{}
    #    |> Core.Files.changeset( params )
    #    |> Repo.insert!( )
  end

  def upload(params, storage) do
    Enum.map(
      params,
      fn file ->
        file = make_unique_name(file)

        case ImageUploader.store({file, %{storage: storage}}) do
          {:ok, name} ->
            path = ImageUploader.storage_dir(1, {file, %{storage: storage}})
            #            %{
            #              mime: file.content_type,
            #              path: %{thumb: "#{path}thumb/", original: "#{path}original/"},
            #              name: name
            #            }
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
      end
    )
    |> Enum.reject(fn file -> Map.has_key?(file, :error) == true end)
  end

  # upload dashboard icons
  def upload_icons(params) do
    storage = "Icons"

    Enum.map(
      params,
      fn file ->
        file = make_unique_name(file)

        case IconFileUploader.store({file, %{storage: storage}}) do
          {:ok, name} ->
            path = IconFileUploader.storage_dir(2, {file, %{storage: storage}})
            #
            #            %{
            #              mime: file.content_type,
            #              path: path,
            #              name: name
            #            }
            bucket = Application.get_env(:core, :ex_aws)[:icon_bucket]
            url = Application.get_env(:core, :ex_aws)[:url]

            %{
              icon: "#{url}#{bucket}/#{path}#{name}"
            }

          {:error, :invalid_file} ->
            %{error: ["invalid icon!"]}

          _ ->
            %{error: ["Icon not uploaded successfully!"]}
        end
      end
    )
  end

  def delete(params) do
    Enum.map(
      params,
      fn %{"name" => name, "path" => %{"original" => original, "thumb" => thumb}} ->
        {:ok, original_filename} =
          ImageUploader.store(
            Application.get_env(:core, :ex_aws)[:bucket] <> "/" <> original <> name
          )

        :ok = ImageUploader.delete(original_filename)

        {:ok, original_filename} =
          ImageUploader.store(
            Application.get_env(:core, :ex_aws)[:bucket] <> "/" <> thumb <> name
          )

        :ok = ImageUploader.delete(original_filename)
      end
    )
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

  def get_icons(icons) do
    icons =
      Enum.map(icons, fn icon ->
        %{path: path, name: name} = icon

        with {:ok, image} <- fetch_icon("#{path}#{name}") do
          image
        end
      end)

    icons
  end

  def fetch_icon(icon) do
    {:ok, url} =
      ExAws.Config.new(:s3)
      |> ExAws.S3.presigned_url(
        :get,
        Application.get_env(:core, :ex_aws)[:icon_bucket],
        icon
        #        [acl: "public_read",
        #        virtual_host: true
        #        expires_in: Application.get_env(:core, :ex_aws)[:icon_expires_in]
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

  def fetch_file(path) do
    {:ok, url} =
      ExAws.Config.new(:s3)
      |> ExAws.S3.presigned_url(
        :get,
        Application.get_env(:core, :ex_aws)[:bucket],
        path,
        expires_in: Application.get_env(:core, :ex_aws)[:expires_in]
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

  def make_unique_name(file, current_datetime \\ DateTime.utc_now()) do
    file_name =
      to_string(DateTime.to_unix(current_datetime, :microsecond)) <> "_" <> file.filename

    Map.merge(file, %{filename: file_name})
  end

  #  def file_size_validation(params, slug) do
  #    Enum.reduce(params, [],
  #      fn %{path: path} = file, acc ->
  #        case File.stat!(path) do
  #          %{size: file_size} ->
  #            file_size = file_size / (1000 * 1000)
  #            case Settings.get_tudo_setting_by(%{slug: slug}) do
  #              nil -> {:error, ["unable get tudo setting!"]}
  #              %{value: value} ->
  #                if file_size <= value do
  #                  [file | acc]
  #                else
  #                  [compress_image(file, file_size) | acc]
  #                end
  #              _ -> {:error, ["something went wrong"]}
  #            end
  #          _ -> {:error, ["unable to get size of #{file.filename}"]}
  #        end
  #      end
  #    )
  #  end

  #  defp compress_image(file, file_size) do
  #    file
  #  end

  #  def compress_resize_and_upload_to_s3(filename, path) do
  #    random = UUID.uuid4()
  #    unique_filename = "#{random}-#{filename}"
  #    {:ok, local} = Application.fetch_env(:app, :local_url)
  #    local_filepath = local <> "/" <> unique_filename
  #    {:ok, body} = Poison.encode(%{resize: %{method: "scale", height: 800}})
  #
  #    case Tinify.from_file(path) do
  #      {:ok, %{url: url}} ->
  #        with {:ok, %Response{body: binary}} <- request("post", url, body),
  #             :ok <- File.write(local_filepath, binary) do
  #        end
  #
  #      {:error, error} ->
  #        raise error
  #    end
  #
  #    {:ok, smaller_image_binary} = File.read(local_filepath)
  #
  #    ExAws.S3.put_object("S3_BUCKET_NAME", unique_filename, smaller_image_binary,
  #      acl: :public_read
  #    )
  #    |> ExAws.request!()
  #
  #    "S3_BUCKET_URL/#{unique_filename}"
  #  end
end
