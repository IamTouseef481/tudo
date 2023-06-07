defmodule CoreWeb.Helpers.EmailHelper do
  #  Core.Emails.EmailsControllerHelper
  @moduledoc false

  use CoreWeb, :core_helper

  import Bamboo.Email
  import SendGrid.Email

  alias Core.{Accounts, Emails}
  alias CoreWeb.Utils.{CommonFunctions, HttpRequest}

  def send_email(
        to,
        subject,
        html_body \\ "",
        sender \\ "send_in_blue",
        body \\ "Body not provided",
        purpose \\ nil,
        sender_email \\ nil
      )

  def send_email(to, subject, html_body, "mailgun", body, purpose, sender_email) do
    to = String.downcase(to)
    #    to = "hammadciit@gmail.com"
    #    to = "dipak241@gmail.com"
    #    to = "tudotest123@gmail.com"

    from =
      if purpose == "invite_cmr" do
        sender_email
      else
        Application.get_env(:core, CoreWeb.Mailer)[:username]
      end

    logger(__MODULE__, to, :info, __ENV__.line)

    new_email()
    |> to(to)
    |> from("TUDO-DoNotReply " <> from)
    #    |> put_header("Reply-To", Application.get_env(:core, CoreWeb.Mailer)[:username])
    |> subject(subject)
    |> html_body(html_body)
    |> text_body(body)
    |> CoreWeb.Mailer.deliver_now()
  end

  def send_email(to, subject, html_body, "sendgrid", body, purpose, sender_email) do
    to = String.downcase(to)
    #    to = "tudotest123@gmail.com"
    from =
      if purpose == "invite_cmr" do
        sender_email
      else
        Application.get_env(:core, :sendgrid)[:username]
      end

    logger(__MODULE__, to, :info, __ENV__.line)

    build()
    |> add_to(to)
    |> put_from(from)
    |> put_subject(subject)
    |> put_html(html_body)
    |> put_text(body)
    |> SendGrid.Mail.send(api_key: Application.get_env(:core, :sendgrid)[:api_key])
  end

  def send_email(to, subject, html_body, "send_in_blue", _, purpose, attr) do
    to = String.downcase(to)
    #    to = "tudotest123@gmail.com"
    from =
      if purpose == "invite_cmr" do
        attr["sender_email"]
      else
        System.get_env("STAGING_EMAIL_SENDER")
      end

    logger(__MODULE__, to, :info, __ENV__.line)

    sender = %{email: from}

    params =
      if Map.has_key?(attr, "url") do
        %{
          sender: sender,
          to: [%{email: to}],
          htmlContent: html_body,
          subject: subject,
          attachment: [%{url: attr["url"]}]
        }
      else
        %{sender: sender, to: [%{email: to}], htmlContent: html_body, subject: subject}
      end

    send_in_blue_email(params)
  end

  def send_email(_, _, _, sender, _, _, _) do
    logger(__MODULE__, sender, :info, __ENV__.line)
    sender
  end

  def create_send_in_blue_contact(params) do
    url = "https://api.sendinblue.com/v3/contacts"

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"},
      {"api-key", System.get_env("SEND_IN_BLUE_API_KEY")}
    ]

    case HttpRequest.post(url, params, headers, []) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  def update_send_in_blue_contact(params) do
    email = params.email
    mobile = params.attributes[:SMS]

    url =
      if is_nil(email) or email == "" do
        "https://api.sendinblue.com/v3/contacts/#{mobile <> "@mailin-sms.com"}"
      else
        "https://api.sendinblue.com/v3/contacts/#{email}"
      end

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"},
      {"api-key", System.get_env("SEND_IN_BLUE_API_KEY")}
    ]

    case HttpRequest.put(url, params, headers, []) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  def get_token do
    CommonFunctions.number()
  end

  def send_notification_on_reset_password(params) do
    %{id: user_id} = Accounts.get_user_by_email(params.login)

    %{language: language, name: _cmr_name} =
      Core.Jobs.JobNotificationHandler.make_notification_data(user_id)

    {:ok, _cmr_notif_job_id} =
      Exq.enqueue(
        Exq,
        "default",
        "CoreWeb.Workers.NotifyWorker",
        [
          "reset_password_for_cmr",
          user_id,
          language,
          "cmr",
          %{}
        ]
      )
  rescue
    _ -> {:error, ["notification can't send!"]}
  end

  def set_token(params) do
    params =
      Map.merge(params, %{
        token: 773_470,
        # token: generate_token(),
        min_count: 1,
        hour_count: 1,
        day_count: 1
      })

    case Emails.get_random_token!(params) do
      nil ->
        case Emails.create_random_tokens(params) do
          {:ok, token} ->
            if params.purpose == "forget_password",
              do: send_notification_on_reset_password(params)

            {:ok, token}

          {:error, error} ->
            {:error, error}
        end

      #        Exq.enqueue_in(
      #          Exq,
      #          "default",
      #          18000,
      #          CoreWeb.Workers.TokenExpireWorker,
      #          [
      #            token.id
      #          ]
      #        )

      %{day_count: day_count, updated_at: token_sent_at} = result ->
        #        Exq.enqueue_in(
        #          Exq,
        #          "default",
        #          18000,
        #          CoreWeb.Workers.TokenExpireWorker,
        #          [
        #            result.id
        #          ]
        #        )
        time_difference = Timex.diff(DateTime.utc_now(), token_sent_at, :hours)

        #        time_difference = Timex.diff(Timex.shift(DateTime.utc_now(), hours: 35), token_sent_at, :hours)
        if time_difference >= 24 do
          case Emails.update_random_tokens(result, %{
                 token: generate_token(),
                 day_count: day_count + 1
               }) do
            {:ok, token} ->
              _notification_on_reset_password =
                if params.purpose == "forget_password" do
                  send_notification_on_reset_password(params)
                end

              {:ok, token}

            {:error, error} ->
              {:error, error}
          end
        else
          case Emails.update_random_tokens(result, %{day_count: day_count + 1}) do
            {:ok, token} ->
              _notification_on_reset_password =
                if params.purpose == "forget_password" do
                  send_notification_on_reset_password(params)
                end

              {:ok, token}

            {:error, error} ->
              {:error, error}
          end
        end
    end
  end

  defp generate_token do
    CommonFunctions.number()
  end

  def send_in_blue_email(params) do
    url = "https://api.sendinblue.com/v3/smtp/email"

    encoded_body = Poison.encode!(params)

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"},
      {"api-key", System.get_env("SEND_IN_BLUE_API_KEY")}
    ]

    case HTTPoison.post(url, encoded_body, headers) do
      {:ok, data} ->
        {:ok, Poison.decode(data.body)}

      exception ->
        logger(__MODULE__, exception, ["Unable to send email through httpoison"], __ENV__.line)
    end
  end
end
