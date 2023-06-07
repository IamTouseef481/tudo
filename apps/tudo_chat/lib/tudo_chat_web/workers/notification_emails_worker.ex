defmodule TudoChatWeb.Workers.NotificationEmailsWorker do
  @moduledoc false
  import TudoChatWeb.Utils.Errors
  alias TudoChatWeb.Utils.CommonFunctions

  def perform(purpose, %{"email" => email} = attr) do
    if send_email?(email, email) do
      %{subject: sub, html_body: body} =
        get_template(%{language: attr["language"], purpose: purpose, attr: attr})

      #    email = "tudotest123@gmail.com"
      case send_email(email, sub, body) do
        #      %Bamboo.Email{} = email ->
        #        {:ok, email}
        {:ok, msg_id} ->
          {:ok, msg_id}

        _ ->
          {:error, ["Invalid Email/ Password or Internet issue!"]}
      end
    else
      {:ok, ["email notification turned off by user"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Error in Email Worker."], __ENV__.line)
  end

  def send_email(to, subject, html_body \\ "", _body \\ "") do
    #        to = "hammadciit@gmail.com"
    #    to = "dipak241@gmail.com"
    IO.puts("----------Sending email to #{to}----------")
    sender = %{email: System.get_env("STAGING_EMAIL_SENDER")}
    url = "https://api.sendinblue.com/v3/smtp/email"

    identify_url = Application.get_env(:core, :identify_host_url)

    params =
      cond do
        identify_url == "localhost" ->
          %{
            sender: sender,
            to: [%{email: to}],
            htmlContent: html_body,
            subject: "Test Server:" <> subject
          }

        true ->
          %{sender: sender, to: [%{email: to}], htmlContent: html_body, subject: subject}
      end

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

  #  def get_template(%{language: lang, purpose: purpose, attr: attr}) do
  #    attr = CommonFunctions.keys_to_atoms(attr)
  #    case purpose do
  #      "friend_request" -> TudoChatWeb.Templates.EmailTemplates.FriendRequest.template(lang, attr)
  #      "friend_request_accepted" -> TudoChatWeb.Templates.EmailTemplates.FriendRequest.template(lang, attr)
  #      #      "invite_cmr" -> CoreWeb.Templates.EmailTemplates.InviteCmr.template(lang, attr)
  #      #      "registration_activation" -> CoreWeb.Templates.EmailTemplates.AccountActivation.template(lang, attr)
  #      #      "forget_password" -> CoreWeb.Templates.EmailTemplates.ForgetPassword.template(lang, attr)
  #      _ ->
  #        %{subject: "Error!", html_body: "<h3>Email data couldn't load</h3>"}
  #      #        CoreWeb.Templates.EmailTemplates.ForgetPassword.template(lang, attr)
  #    end
  #  end

  def get_template(%{language: lang, purpose: purpose, attr: attr}) do
    attr = CommonFunctions.keys_to_atoms(attr)

    case purpose do
      "friend_request" ->
        getting_sendinblue_email_template(70, lang, attr)

      "friend_request_accepted" ->
        getting_sendinblue_email_template(70, lang, attr)

      #      "invite_cmr" -> CoreWeb.Templates.EmailTemplates.InviteCmr.template(lang, attr)
      #      "registration_activation" -> CoreWeb.Templates.EmailTemplates.AccountActivation.template(lang, attr)
      #      "forget_password" -> CoreWeb.Templates.EmailTemplates.ForgetPassword.template(lang, attr)
      _ ->
        %{subject: "Error!", html_body: "<h3>Email data couldn't load</h3>"}
        #        CoreWeb.Templates.EmailTemplates.ForgetPassword.template(lang, attr)
    end
  end

  def getting_sendinblue_email_template(id, _lang, attrs, subject_attrs \\ false)
      when is_number(id) do
    #    subject attributes used for adding attrs to notification messages
    url = "https://api.sendinblue.com/v3/smtp/templates/#{id}"

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"},
      {"api-key", System.get_env("SEND_IN_BLUE_API_KEY")}
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %{status_code: 200, body: body}} ->
        case Poison.decode(body) do
          {:ok, %{"htmlContent" => html, "subject" => subject}} ->
            if subject_attrs do
              %{subject: add_attributes_to_template(subject, attrs), html_body: html}
            else
              %{subject: subject, html_body: add_attributes_to_template(html, attrs)}
            end

          exception ->
            logger(__MODULE__, exception, ["Something went wrong."], __ENV__.line)
        end

      {:ok, %{status_code: 401}} ->
        {:error, ["Unauthorized for API"]}

      exception ->
        logger(__MODULE__, exception, ["Bad Response from API"], __ENV__.line)
    end
  end

  def add_attributes_to_template(template, params) do
    #    template = ~s"""
    #    \"#{template}\"
    #    """
    param_keys = Map.keys(params)

    #    our pattern strings in message body (e.g job_id) and keys of params sending as last argument from enqeue (job_id)should be same
    Enum.reduce(param_keys, template, fn param_key, body ->
      String.replace(body, "{{#{to_string(param_key)}}}", to_string(params[param_key]))
    end)
  end

  def send_email?(purpose, email) do
    case apply(Core.Accounts, :get_user_by_email, [email]) do
      %{id: user_id} ->
        case apply(Core.Emails, :get_email_settings_by_slug, [user_id, purpose]) do
          [%{is_active: false}] -> false
          _ -> true
        end

      nil ->
        false
    end
  end
end
