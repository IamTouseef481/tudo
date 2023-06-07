defmodule CoreWeb.PDF.MakePDF do
  alias CoreWeb.Controllers.RestFileController
  alias CoreWeb.Workers.NotificationEmailsWorker
  alias Core.BSP

  def send_email_with_attachment(
        purpose,
        %{"email" => email} = attr,
        %{
          branch_name: name,
          branch_phone: phone,
          branch_address: address,
          profile_pictures: profile_pictures,
          branch_id: branch_id
        }
      ) do
    filename = "Business door Sticker " <> name <> " (" <> (branch_id |> to_string) <> ")"

    profile_picture =
      if is_nil(profile_pictures) || profile_pictures == [] do
        ""
      else
        List.first(profile_pictures) |> Map.get("original")
      end

    %{html_body: html} =
      NotificationEmailsWorker.getting_sendinblue_email_template(100, nil, %{
        "branch_name" => name,
        "business_phone" => phone,
        "business_email" => email,
        "business_address" => address,
        "branch_availability_qr_code" => generate_QR_code(branch_id),
        "branch_logo" => profile_picture
      })

    {:ok, filename} =
      PdfGenerator.generate(html,
        page_size: "A4",
        shell_params: ["--dpi", "300"],
        filename: filename
      )

    File.rename(filename, filename)

    case RestFileController.upload_file(%{"files" => [filename]}) do
      files ->
        Enum.each(files, fn file ->
          case file do
            %{original: url} ->
              insert_url(url, branch_id)
              NotificationEmailsWorker.perform(purpose, Map.merge(attr, %{"url" => url}), "cmr")
          end
        end)
    end

    remove_local_file(filename)
  end

  def remove_local_file(filename) do
    File.rm(filename)

    String.replace(filename, ".pdf", ".html")
    |> File.rm()
  end

  def generate_QR_code(branch_id) do
    qr_code_png =
      "https://tudo.app/availability/#{branch_id}"
      |> QRCodeEx.encode()
      |> QRCodeEx.png()

    File.write("./qr_code.png", qr_code_png, [:binary])

    image = %Plug.Upload{
      content_type: "application/png",
      filename: "qr_code.png",
      path: "./qr_code.png"
    }

    original =
      case CoreWeb.Controllers.ImageController.upload([image], "services") do
        [] -> ""
        [head | _] -> head |> Map.get(:original)
      end

    File.rm("./qr_code.png")
    original
  end

  def insert_url(url, branch_id) do
    case BSP.get_branch!(branch_id) do
      nil -> ["No branch found"]
      branch -> BSP.update_branch(branch, %{outdoor_sticker_pdf: url})
    end
  end
end
