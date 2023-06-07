defmodule CoreWeb.Templates do
  @moduledoc false

  alias CoreWeb.Utils.DateTimeFunctions
  alias CoreWeb.Workers.NotificationEmailsWorker

  def get_template(%{language: lang, purpose: purpose, attr: attr}) do
    datetime =
      DateTimeFunctions.convert_utc_time_to_local_time()
      |> DateTimeFunctions.reformat_datetime_for_emails()

    {year, _, _} = Date.utc_today() |> Date.to_erl()
    attr = Map.merge(attr, %{date_time: datetime, year: year})
    #    getting templates from code
    #    case purpose do
    #      "invite_cmr" -> CoreWeb.Templates.EmailTemplates.InviteCmr.template(lang, attr)
    #      "invite_employee" -> CoreWeb.Templates.EmailTemplates.InviteEmployee.template(lang, attr)
    #      "registration_activation" -> CoreWeb.Templates.EmailTemplates.AccountActivation.template(lang, attr)
    #      "forget_password" -> CoreWeb.Templates.EmailTemplates.ForgetPassword.template(lang, attr)
    #      _ -> CoreWeb.Templates.EmailTemplates.ForgetPassword.template(lang, attr)
    #    end

    #    getting templates from send in blue
    case purpose do
      "invite_cmr" ->
        NotificationEmailsWorker.getting_sendinblue_email_template(19, lang, attr)

      "invite_employee" ->
        NotificationEmailsWorker.getting_sendinblue_email_template(17, lang, attr)

      "registration_activation" ->
        NotificationEmailsWorker.getting_sendinblue_email_template(20, lang, attr)

      "forget_password" ->
        NotificationEmailsWorker.getting_sendinblue_email_template(21, lang, attr)

      _ ->
        NotificationEmailsWorker.getting_sendinblue_email_template(21, lang, attr)
    end
  end
end
