defmodule CoreWeb.Controllers.FileController do
  @moduledoc false

  use CoreWeb, :controller

  alias CoreWeb.Services.{FileUploader}

  def upload_file(params, storage) do
    Enum.map(
      params,
      fn file ->
        case FileUploader.store({file, %{storage: storage}}) do
          {:ok, name} ->
            path = FileUploader.storage_dir(1, {file, %{storage: storage}})
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
end
