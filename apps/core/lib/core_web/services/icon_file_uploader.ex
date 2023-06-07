defmodule CoreWeb.Services.IconFileUploader do
  @moduledoc false
  use Arc.Definition
  import CoreWeb.Utils.Errors

  # To add a thumbnail version:
  @versions [:original]

  # Override the bucket on a per definition basis:
  def bucket do
    Application.get_env(:core, :ex_aws)[:icon_bucket]
  end

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .jpeg .gif .png .doc .txt .xlxs .ppt .docx .xls .zip .rar .pdf .mp4 .mp3 .avi .flv .mov .aac .svg
    .JPG .JPEG .GIF .PNG .DOC .TXT .XLXS .PPT .DOCX .XLS .ZIP .RAR .PDF .MP4 .MP3 .AVI .FLV .MOV .AAC .SVG)
    |> Enum.member?(Path.extname(file.file_name))
  end

  # Define a thumbnail transformation:
  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 100x100^ -gravity center -extent 100x100 -format png", :png}
  end

  # Override the persisted filenames:
  #  def filename(version, {file, scope}) do
  #    Path.rootname(file.file_name)
  #    name
  #  end

  def storage_dir(_version, {_file, scope}) do
    logger(__MODULE__, scope.storage, :info, __ENV__.line)
    "#{scope.storage}/"
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
    Application.get_env(:core, :ex_aws)[:icon_acl]
  end
end
