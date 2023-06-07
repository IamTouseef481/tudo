defmodule TudoChatWeb.Upload.MessageFileUploader do
  @moduledoc false
  use Arc.Definition

  # Include ecto support (requires package arc_ecto installed):
  # use Arc.Ecto.Definition

  # To add a thumbnail version:
  @versions [:original]

  # Override the bucket on a per definition basis:
  def bucket do
    Application.get_env(:tudo_chat, :ex_aws)[:message_bucket]
  end

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.accdb .accde .accdr .accdt .aclscript .csv .dap .dat .dbf .dbp .del .dfe .doc .docb .docm
     .docx .dot .dotm .dotx .dsn .eap .inx .json .mdb .model .pdf .pot .potm .potx .ppam .pps .ppsm
     .ppsx .ppt .pptm .pptx .prf .ps1 .rec .rpt .sldm .sldx .txt .vbs .xbrl .xla .xlam .xll .xlm
     .xlt .xltm .xltx .xlw .xml .zip .acl .aclapp .aclx .fmt .layout .wsp .avi .bmp .csv .doc .docm
     .docx .gif .gz .jpeg .jpg .md .mov .mp3 .mp4 .m4a .m4v .mpeg .odg .ogg . odp .ods .odt .pages
     .pdf .pgp .png .ppt .pptm .pptx .rar .rtf .svg .tgz .ogv .wmv .mpg .ogv .3gp .3g2 .tif .tiff
     .txt .vcs .vsd .vsdx .vss .wav .wma .wmv .wps .xcf .xls .xlsb .xlsm .xlsx .xlt .xps .zip .zipx
     .dwg .dot .dotx .pict .pic .psd .qtif .psd .sgi .mpeg .heic .hevc .heif .ts .webm .mkv .aac
     .amr .flac .mid .xmf .mxmf .rtttl .rtx .ota .imy .rtf .htm .mht .dic .thmx .odt .key
     .PNG .JPEG .JPG)
    |> Enum.member?(Path.extname(file.file_name))
  end

  # Define a thumbnail transformation:
  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 100x100^ -gravity center -extent 100x100 -format png"}
  end

  # Override the persisted filenames:
  #  def filename(version, {file, scope}) do
  #    fileName= Path.rootname(file.file_name)
  #    name
  #  end

  def storage_dir(_version, {_file, scope}) do
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
    Application.get_env(:tudo_chat, :ex_aws)[:acl]
  end
end
