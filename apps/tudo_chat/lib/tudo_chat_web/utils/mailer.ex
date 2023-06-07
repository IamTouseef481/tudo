defmodule TudoChatWeb.Utils.Mailer do
  @moduledoc false

  def number(min \\ 100_000, max \\ 999_999) do
    # :rand.uniform(count)
    Enum.random(min..max)
  end

  def string(length \\ 24) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end

  def send_email(to, subject, html_body \\ "", body \\ "") do
    import Bamboo.Email

    new_email(
      to: to,
      from: "from email address",
      subject: subject,
      html_body: html_body,
      text_body: body
    )
    |> TudoChatWeb.Mailer.deliver_later()
  end
end
