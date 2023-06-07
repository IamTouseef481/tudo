defmodule CoreWeb.Services.FileUploader do
  @moduledoc false
  use Arc.Definition
  import CoreWeb.Utils.Errors

  # To add a thumbnail version:
  @versions [:original]

  # Override the bucket on a per definition basis:
  # def bucket do
  #   :custom_bucket_name
  # end

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.pdf .PDF)
    |> Enum.member?(Path.extname(file.file_name))
  end

  # Override the persisted filenames:
  #  def filename(version, {file, scope}) do
  #    fileName= Path.rootname(file.file_name)
  #    name
  #  end

  def storage_dir(version, {_file, scope}) do
    logger(__MODULE__, scope.storage, :info, __ENV__.line)

    _folder =
      case version do
        :thumb ->
          "#{scope.storage}/thumb/"

        :original ->
          "#{scope.storage}/original/"

        :compressed ->
          "#{scope.storage}/original/"

        1 ->
          "#{scope.storage}/"
          #        2 -> "#{scope.storage}/"
      end

    # current_datetime = DateTime.utc_now()
    # current_year = to_string(current_datetime.year)
    # current_month = to_string(current_datetime.month)
    # current_day = to_string(current_datetime.day)
    # "#{current_year}/#{current_month}/#{current_day}/#{folder}"
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
    Application.get_env(:core, :ex_aws)[:acl]
  end
end
