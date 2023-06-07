defmodule TudoChatWeb.Upload.FileUploader do
  @moduledoc false
  use Arc.Definition

  # Include ecto support (requires package arc_ecto installed):
  # use Arc.Ecto.Definition

  # To add a thumbnail version:
  @versions [:original, :thumb]

  # Override the bucket on a per definition basis:
  # def bucket do
  #   :custom_bucket_name
  # end

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .jpeg .gif .png .tiff .JPG .JPEG .GIF .PNG .TIFF)
    |> Enum.member?(Path.extname(file.file_name))
  end

  # Define a thumbnail transformation:
  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 100x100^ -gravity center -extent 100x100"}
  end

  def transform(:original, {%{path: path}, _}) do
    case File.stat!(path) do
      %{size: file_size} ->
        file_size = file_size / (1000 * 1000)

        case apply(Core.Settings, :get_tudo_setting_by, [%{slug: "max_file_size"}]) do
          nil ->
            :noaction

          %{value: max_file_size} ->
            cond do
              file_size <= max_file_size -> :noaction
              file_size > max_file_size and file_size <= 1.5 -> compress_image(path, 2)
              file_size > 1.5 and file_size <= 3 -> compress_image(path, 3)
              file_size > 3 and file_size <= 4 -> compress_image(path, 4)
              file_size > 4 and file_size <= 8 -> compress_image(path, 5)
              file_size > 8 and file_size <= 16 -> compress_image(path, 6)
              file_size > 16 and file_size <= 32 -> compress_image(path, 8)
              file_size > 32 and file_size <= 50 -> compress_image(path, 10)
              file_size > 50 -> compress_image(path, 20)
            end

          _ ->
            :noaction
        end

      _ ->
        :noaction
    end
  end

  defp compress_image(path, count) do
    case Fastimage.size(path) do
      {:ok, %Fastimage.Dimensions{height: height, width: width}} ->
        height = height / count
        width = width / count

        {:convert,
         "-strip -thumbnail #{width}x#{height}^ -gravity center -extent #{width}x#{height}"}

      _ ->
        :noaction
    end
  end

  # Override the persisted filenames:
  #  def filename(version, {file, scope}) do
  #    fileName= Path.rootname(file.file_name)
  #    name
  #  end

  def storage_dir(version, {_file, scope}) do
    folder =
      case version do
        :thumb ->
          "#{scope.storage}/thumb/"

        :original ->
          "#{scope.storage}/original/"

        1 ->
          "#{scope.storage}/"
          #        2 -> "#{scope.storage}/"
      end

    #      if version == 2 do
    #        folder
    #        else
    current_datetime = DateTime.utc_now()
    current_year = to_string(current_datetime.year)
    current_month = to_string(current_datetime.month)
    current_day = to_string(current_datetime.day)
    "#{current_year}/#{current_month}/#{current_day}/#{folder}"
    #      end
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  def s3_object_headers(_version, {file, _scope}) do
    [content_type: MIME.from_path(file.file_name)]
  end

  def acl(_version, {_file, _scope}) do
    Application.get_env(:tudo_chat, :ex_aws)[:acl]
  end
end
