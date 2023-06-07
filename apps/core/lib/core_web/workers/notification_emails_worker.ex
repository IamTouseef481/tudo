defmodule CoreWeb.Workers.NotificationEmailsWorker do
  @moduledoc false
  import CoreWeb.Utils.{Errors, CommonFunctions}
  alias Core.{Accounts, Emails}
  alias CoreWeb.Helpers.AdminNotificationSettingsHelper, as: ADS

  alias CoreWeb.Templates.EmailTemplates.{
    AcceptJobChangesForCmr,
    AccountActivation,
    AdjustInvoiceForBsp,
    AdjustInvoiceForCmr,
    CancelJobForBsp,
    CancelJobForCmr,
    CreateJobConfirmedForBsp,
    CreateJobConfirmedForCmr,
    CreateJobPendingForBsp,
    CreateJobPendingForCmr,
    ForgetPassword,
    InviteCmr,
    InviteEmployee,
    JobInvoice,
    ManageDispute,
    PaymentMade,
    RaiseDispute,
    RejectChanges,
    RescheduleJobForBsp,
    RescheduleJobForCmr,
    UpdatePlatformTerms
  }

  def perform(purpose, %{"email" => email} = attr, role \\ "cmr") do
    #    email = "tanbitsanonymous@gmail.com"
    if ADS.check_admin_email_permission(role, purpose) and send_email?(purpose, email) do
      temp_params = %{language: attr["language"], purpose: purpose, attr: attr}
      #      case get_template(temp_params) do #getting from code files
      # getting from send in blue server
      case get_template(temp_params, "send_in_blue") do
        %{subject: subject, html_body: body} ->
          #    email = "tudotest123@gmail.com"
          sender =
            if purpose in [
                 "forget_password",
                 "registration_activation",
                 #            "invite_cmr", Send Grid Allow Verify Sender to send Email That's Why We Use  Send in Blue
                 "invite_employee",
                 "send_temporary_password"
               ],
               do: "sendgrid",
               else: "send_in_blue"

          subject =
            cond do
              Application.get_env(:core, :identify_host_url) == "localhost" ->
                "Test Server: " <> subject

              Application.get_env(:core, :identify_host_url) == "staging.tudo.app" ->
                "Staging Server: " <> subject

              true ->
                subject
            end

          case CoreWeb.Helpers.EmailHelper.send_email(
                 email,
                 subject,
                 body,
                 sender,
                 "Body not provided",
                 purpose,
                 attr
               ) do
            #       this clause will match when Bamboo used for sending email
            %Bamboo.Email{} = email ->
              {:ok, email}

            #       this clause will match when send in blue API used for sending email
            {:ok, msg_id} ->
              {:ok, msg_id}

            :ok ->
              {:ok, "email sent"}

            {:error, error} ->
              {:error, error}

            _all ->
              {:error, ["Invalid Email/ Password or Internet issue!"]}
          end

        {:error, error} ->
          {:error, error}
      end
    else
      {:error, ["email notification turned off by user or TUDO Admin"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["error in email sending"], __ENV__.line)
  end

  def get_template(%{language: lang, purpose: purpose, attr: attr}) do
    attr = keys_to_atoms(attr)

    case purpose do
      "create_job_confirmed_for_cmr" ->
        CreateJobConfirmedForCmr.template(lang, attr)

      "create_job_confirmed_for_bsp" ->
        CreateJobConfirmedForBsp.template(lang, attr)

      "create_job_pending_for_cmr" ->
        CreateJobPendingForCmr.template(lang, attr)

      "create_job_pending_for_bsp" ->
        CreateJobPendingForBsp.template(lang, attr)

      "cancel_job_for_cmr" ->
        CancelJobForCmr.template(lang, attr)

      "cancel_job_for_bsp" ->
        CancelJobForBsp.template(lang, attr)

      "invoice_ready_for_cmr" ->
        JobInvoice.template(lang, attr)

      "adjust_invoice_for_bsp" ->
        AdjustInvoiceForBsp.template(lang, attr)

      "adjusted_invoice_for_cmr" ->
        AdjustInvoiceForCmr.template(lang, attr)

      "raise_dispute_for_bsp" ->
        RaiseDispute.template(lang, attr)

      "manage_dispute_for_cmr" ->
        ManageDispute.template(lang, attr)

      "payment_made" ->
        PaymentMade.template(lang, attr)

      "reject_job_changes_for_bsp" ->
        RejectChanges.template(lang, attr)

      "accept_job_changes_for_bsp" ->
        AcceptJobChangesForCmr.template(lang, attr)

      "reschedule_job_for_bsp" ->
        RescheduleJobForBsp.template(lang, attr)

      "reschedule_job_for_cmr" ->
        RescheduleJobForCmr.template(lang, attr)

      "invite_employee" ->
        InviteEmployee.template(lang, attr)

      "update_platform_terms" ->
        UpdatePlatformTerms.template(lang, attr)

      "invite_cmr" ->
        InviteCmr.template(lang, attr)

      "registration_activation" ->
        AccountActivation.template(lang, attr)

      "forget_password" ->
        ForgetPassword.template(lang, attr)

      _ ->
        %{subject: "Error!", html_body: "<h3>Email data couldn't load</h3>"}
        # ForgetPassword.template(lang, attr)
    end
  end

  def get_template(%{language: lang, purpose: purpose, attr: attr}, "send_in_blue") do
    attr = keys_to_atoms(attr)

    {year, _, _} =
      Date.utc_today()
      |> Date.to_erl()

    attr = if Map.has_key?(attr, :year), do: attr, else: Map.merge(attr, %{year: year})

    cond do
      Map.has_key?(attr, :job_id) ->
        %{id: branch_id} = Core.BSP.get_branch_by_job_id(attr.job_id)
        get_user_selected_sendinblue_template(purpose, branch_id, lang, attr)

      Map.has_key?(attr, :branch_id) ->
        get_user_selected_sendinblue_template(purpose, attr.branch_id, lang, attr)

      true ->
        default_template(lang, purpose, attr)
    end
  end

  def get_user_selected_sendinblue_template(purpose, branch_id, lang, attr) do
    case Core.Emails.get_template_id_by(purpose, branch_id) do
      %{send_in_blue_email_template_id: template_id} when template_id |> is_integer() ->
        getting_sendinblue_email_template(template_id, lang, attr)

      _ ->
        default_template(lang, purpose, attr)
    end
  end

  # TODO: Get these default template from the table(email_templates).
  def default_template(lang, purpose, attr) do
    case purpose do
      "create_job_confirmed_for_cmr" ->
        getting_sendinblue_email_template(1, lang, attr)

      "create_job_confirmed_for_bsp" ->
        getting_sendinblue_email_template(2, lang, attr)

      "create_job_pending_for_cmr" ->
        getting_sendinblue_email_template(3, lang, attr)

      "create_job_pending_for_bsp" ->
        getting_sendinblue_email_template(4, lang, attr)

      "cancel_job_for_cmr" ->
        getting_sendinblue_email_template(5, lang, attr)

      "cancel_job_for_bsp" ->
        getting_sendinblue_email_template(6, lang, attr)

      "invoice_ready_for_cmr" ->
        getting_sendinblue_email_template(7, lang, attr)

      "adjust_invoice_for_bsp" ->
        getting_sendinblue_email_template(8, lang, attr)

      "adjusted_invoice_for_cmr" ->
        getting_sendinblue_email_template(9, lang, attr)

      "raise_dispute_for_bsp" ->
        getting_sendinblue_email_template(10, lang, attr)

      "manage_dispute_for_cmr" ->
        getting_sendinblue_email_template(11, lang, attr)

      "payment_made" ->
        getting_sendinblue_email_template(12, lang, attr)

      "reject_job_changes_for_bsp" ->
        getting_sendinblue_email_template(13, lang, attr)

      "accept_job_changes_for_bsp" ->
        getting_sendinblue_email_template(14, lang, attr)

      "reschedule_job_for_bsp" ->
        getting_sendinblue_email_template(15, lang, attr)

      "reschedule_job_for_cmr" ->
        getting_sendinblue_email_template(16, lang, attr)

      "update_platform_terms" ->
        getting_sendinblue_email_template(18, lang, attr)

      "invite_employee" ->
        getting_sendinblue_email_template(17, lang, attr)

      "invite_cmr" ->
        getting_sendinblue_email_template(85, lang, attr)

      "registration_activation" ->
        getting_sendinblue_email_template(20, lang, attr)

      "forget_password" ->
        getting_sendinblue_email_template(21, lang, attr)

      "job_request_to_bsp_on_demand" ->
        getting_sendinblue_email_template(78, lang, attr)

      "send_temporary_password" ->
        getting_sendinblue_email_template(92, lang, attr)

      "BSP_Availability_QR_Code_Email" ->
        getting_sendinblue_email_template(91, lang, attr)

      "bsp_profile_activated" ->
        getting_sendinblue_email_template(69, lang, attr)

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

          _all ->
            {:error, ["error--"]}
        end

      {:ok, %{status_code: 401}} ->
        {:error, ["Unauthorized for API"]}

      {:ok, %{status_code: 503}} ->
        {:error, ["Unable to get email template"]}

      {:error, %{reason: :timeout}} ->
        {:error, ["Request time out!"]}

      _all ->
        {:error, ["Bad response from APi"]}
    end
  end

  def getting_sendinblue_email_template_by(id)
      when is_number(id) do
    url = "https://api.sendinblue.com/v3/smtp/templates/#{id}"

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"},
      {"api-key", System.get_env("SEND_IN_BLUE_API_KEY")}
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status_code: 401}} ->
        {:error, ["Unauthorized for API"]}

      {:ok, %{status_code: 503}} ->
        {:error, ["Unable to get email template"]}

      {:error, %{reason: :timeout}} ->
        {:error, ["Request time out!"]}

      _all ->
        {:error, ["Bad response from APi"]}
    end
  end

  def getting_sendinblue_email_template_by(_), do: {:error, ["Template Id is missing"]}

  ################################################### TEMPLATES DATA FOR CLIENT############################################################

  def getting_template_attributes do
    url = "https://api.sendinblue.com/v3/smtp/templates?limit=500"

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"},
      {"api-key", System.get_env("SEND_IN_BLUE_API_KEY")}
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %{status_code: 200, body: body}} ->
        case Poison.decode(body) do
          {:ok, %{"templates" => templates}} ->
            # Enum.count(templates)
            Enum.reduce(templates, %{}, fn
              %{"htmlContent" => html, "subject" => subject}, acc ->
                #              {:ok, %{"htmlContent" => html, "subject" => subject}} ->
                if List.flatten(Regex.scan(~r/{{[\w]+}}/, html)) == [] do
                  acc
                else
                  Map.put(acc, subject, List.flatten(Regex.scan(~r/{{[\w]+}}/, html)))
                end

              _, acc ->
                acc
            end)
        end
    end
  end

  #  def getting_all_sendinblue_email_templates(attrs) do
  #    url = "https://api.sendinblue.com/v3/smtp/templates?limit=50&offset=0&sort=desc"
  #    case HTTPoison.get(url, @headers) do
  #      {:ok, %{status_code: 200, body: body}} ->
  #        case Poison.decode(body) do
  #          {:ok, %{"templates" => [%{"htmlContent" => html} | _] = templates} = _data} ->
  ##            File.write!("email.html", html)
  #            {:ok, html}
  #          all ->
  #            {:error, ["error--"]}
  #        end
  #      {:ok, %{status_code: 401} = data} ->
  #        {:error, ["Unauthorized for API"]}
  #      all ->
  #        {:error, ["Bad response from APi"]}
  #    end
  #  end

  def add_attributes_to_template(template, params) do
    #    template = ~s"""
    #    \"#{template}\"
    #    """
    param_keys = Map.keys(params)

    #    our pattern strings in message body (e.g job_id) and keys of params sending as last argument from enqeue (job_id)should be same
    Enum.reduce(
      param_keys,
      template,
      fn param_key, body ->
        String.replace(body, "{{#{to_string(param_key)}}}", to_string(params[param_key]))
      end
    )
  end

  def send_email?(purpose, email) do
    case Accounts.get_user_by_email(email) do
      %{id: user_id} ->
        case Emails.get_email_settings_by_slug(user_id, purpose) do
          [%{is_active: false}] -> false
          _ -> true
        end

      nil ->
        true
    end
  end
end
