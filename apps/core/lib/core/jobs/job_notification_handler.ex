defmodule Core.Jobs.JobNotificationHandler do
  @moduledoc false

  import CoreWeb.Utils.Errors

  alias Core.{Accounts, BSP, Employees, Invoices, Jobs, Payments, Regions}
  alias CoreWeb.Utils.CommonFunctions
  alias CoreWeb.Utils.DateTimeFunctions, as: DT

  def make_notification_data(user_id) do
    %{language_id: language_id, name: user_name} =
      case Accounts.get_user!(user_id) do
        %{
          language_id: language_id,
          profile: %{"first_name" => first_name, "last_name" => last_name}
        } ->
          %{language_id: language_id, name: first_name <> " " <> last_name}

        %{language_id: language_id} ->
          %{language_id: language_id, name: ""}

        _ ->
          %{language_id: nil, name: ""}
      end

    language =
      if language_id == nil do
        "EN"
      else
        case Regions.get_languages(language_id) do
          %{code: language} -> language
          _ -> "EN"
        end
      end

    %{language: String.downcase(language), name: user_name}
  end

  def make_attributes_for_email(job_id, user_id) do
    with %{
           id: job_id,
           title: title,
           service_type_id: service_type,
           arrive_at: arrive_at,
           cost: cost,
           employee_id: emp_id,
           inserted_by: cmr_id,
           location_dest: _job_location,
           job_status_id: job_status,
           waiting_arrive_at: job_new_time,
           job_bsp_status_id: job_bsp_status,
           branch_service_id: bs_id,
           job_cmr_status_id: job_cmr_status,
           cancel_reason: cancel_reason,
           dispute_reason: dispute_reason
         } <- Jobs.get_job(job_id),
         %{language_id: language_id, gender: gender, email: email} <- Accounts.get_user!(user_id),
         %{user_id: bsp_user_id, name: business_name} <-
           BSP.get_business_by_branch_service_id(bs_id),
         %{name: bsp_branch_profile_name} <- BSP.get_branch_by_branch_service(bs_id),
         %{profile: %{"first_name" => bsp_first_name, "last_name" => bsp_last_name}} <-
           Accounts.get_user!(bsp_user_id),
         %{profile: %{"first_name" => cmr_first_name, "last_name" => cmr_last_name}} <-
           Accounts.get_user!(cmr_id) do
      %{emp_first_name: emp_first_name, emp_last_name: emp_last_name} =
        if is_nil(emp_id) do
          %{emp_first_name: nil, emp_last_name: nil}
        else
          %{user_id: emp_user_id} = Employees.get_employee(emp_id)

          %{profile: %{"first_name" => emp_first_name, "last_name" => emp_last_name}} =
            Accounts.get_user!(emp_user_id)

          %{emp_first_name: emp_first_name, emp_last_name: emp_last_name}
        end

      gender =
        if is_binary(gender) do
          cond do
            String.contains?(gender, ["male", "Male", "MALE"]) -> "Mr."
            String.contains?(gender, ["female", "Female", "FEMALE"]) -> "Ms."
            true -> ""
          end
        else
          ""
        end

      language =
        if language_id == nil do
          "EN"
        else
          %{code: language} = Regions.get_languages(language_id)
          language
        end

      {year, _, _} = Date.utc_today() |> Date.to_erl()

      #     custom format of datetime for emails
      arrive_at = DT.convert_utc_time_to_local_time(arrive_at)
      job_new_time = DT.convert_utc_time_to_local_time(job_new_time)
      arrive_at = DT.reformat_datetime_for_emails(arrive_at)
      job_new_time = DT.reformat_datetime_for_emails(job_new_time)

      %{
        job_id: job_id,
        job_title: title,
        service_type: service_type,
        job_time: arrive_at,
        email: email,
        job_status: job_status,
        gender: gender,
        year: year,
        language: String.downcase(language),
        bsp_first_name: bsp_first_name,
        bsp_last_name: bsp_last_name,
        job_new_time: job_new_time,
        emp_first_name: emp_first_name,
        emp_last_name: emp_last_name,
        job_cancel_reason: cancel_reason,
        cmr_first_name: cmr_first_name,
        cmr_last_name: cmr_last_name,
        job_cost: cost,
        job_bsp_status: job_bsp_status,
        job_cmr_status: job_cmr_status,
        local_currency: "Dollars",
        bsp_branch_profile_name: bsp_branch_profile_name,
        business_name: business_name,
        job_change_reason: "",
        rejection_reason: "",
        changes_for_reschedule: "",
        dispute_reason: dispute_reason
        #        job_location: job_location
      }
    else
      _ -> nil
    end
  end

  defp make_invoice_attributes_for_email(job_id, cmr_paid_amount) do
    case Invoices.get_invoice_by_job_id(job_id) do
      [
        %{
          id: invoice_id,
          final_amount: invoice_amount,
          inserted_at: invoice_time,
          amounts: charges,
          discounts: discounts,
          taxes: taxes,
          total_charges: total_charges,
          total_discount: total_discount,
          total_tax: total_tax,
          comment: comment,
          payment_type: payment_method,
          adjust_reason: adjust_reason
        }
      ] ->
        #        custom format of datetime for emails
        invoice_time = DT.convert_utc_time_to_local_time(invoice_time)
        invoice_time = DT.reformat_datetime_for_emails(invoice_time)

        #        ---------------invoice email modifications in values----------------------
        invoice_amount =
          if cmr_paid_amount do
            case Payments.get_payment_by_job_id(job_id) do
              [%{total_transaction_amount: amount} | _] -> amount
              _ -> nil
            end
          else
            invoice_amount
          end

        invoice_amount =
          if is_float(invoice_amount),
            do: :erlang.float_to_binary(invoice_amount, decimals: 2),
            else: invoice_amount

        total_charges =
          if is_float(total_charges),
            do: :erlang.float_to_binary(total_charges, decimals: 2),
            else: total_charges

        total_discount =
          if is_float(total_discount),
            do: :erlang.float_to_binary(total_discount, decimals: 2),
            else: total_discount

        total_tax =
          if is_float(total_tax),
            do: :erlang.float_to_binary(total_tax, decimals: 2),
            else: total_tax

        charges = CommonFunctions.keys_to_atoms(charges)

        charges_details =
          Enum.reduce(charges, %{charges: "", counter: 1}, fn
            %{service_title: service_title, unit_price: unit_price, quantity: quantity} = _charge,
            acc ->
              total =
                if is_float(unit_price * quantity),
                  do: :erlang.float_to_binary(unit_price * quantity, decimals: 2),
                  else: unit_price * quantity

              unit_price =
                if is_float(unit_price),
                  do: :erlang.float_to_binary(unit_price, decimals: 2),
                  else: unit_price

              charges_string =
                "#{acc[:counter]}. #{service_title}  <span style='float:right'>#{total}</span> <br/>Unit Price: #{unit_price} * Qty #{quantity}<br/>"

              charges_acc = acc[:charges] <> charges_string
              %{charges: charges_acc, counter: acc[:counter] + 1}
          end)

        discounts = CommonFunctions.keys_to_atoms(discounts)
        discounts = CoreWeb.Controllers.InvoiceController.add_discount_value(discounts, charges)

        discounts_details =
          Enum.reduce(discounts, %{discounts: "", counter: 1}, fn
            %{title: discount_title, value: value, amount: discount_amount} = discount, acc ->
              percentage = if discount.is_percentage, do: "#{value}%", else: ""

              discount_amount =
                if is_float(discount_amount),
                  do: :erlang.float_to_binary(discount_amount, decimals: 2),
                  else: discount_amount

              discount_string =
                "#{acc[:counter]}. #{discount_title} #{percentage}  <span style='float:right'>#{discount_amount}</span><br/>"

              discounts_acc = acc[:discounts] <> discount_string
              %{discounts: discounts_acc, counter: acc[:counter] + 1}
          end)

        taxes = CommonFunctions.keys_to_atoms(taxes)
        taxes = CoreWeb.Controllers.InvoiceController.add_tax_value(taxes, charges)

        taxes_details =
          Enum.reduce(taxes, %{taxes: "", counter: 1}, fn
            %{title: tax_title, value: value, amount: tax_amount} = tax, acc ->
              percentage = if tax.is_percentage, do: "#{value}%", else: ""

              tax_amount =
                if is_float(tax_amount),
                  do: :erlang.float_to_binary(tax_amount, decimals: 2),
                  else: tax_amount

              tax_string =
                "#{acc[:counter]}. #{tax_title} #{percentage}  <span style='float:right'>#{tax_amount}</span><br/>"

              taxes_acc = acc[:taxes] <> tax_string
              %{taxes: taxes_acc, counter: acc[:counter] + 1}
          end)

        #      -----------------------------------------------
        %{
          invoice_id: invoice_id,
          final_amount: invoice_amount,
          inserted_at: invoice_time,
          amounts: charges_details.charges,
          discounts: discounts_details.discounts,
          taxes: taxes_details.taxes,
          total_charges: total_charges,
          total_discount: total_discount,
          total_tax: total_tax,
          comment: comment,
          payment_type: payment_method,
          invoice_adjust_reason: adjust_reason
        }

      _ ->
        %{}
    end
  end

  #  create job (confirmed)
  def send_notification_for_create_job(
        %{
          job_cmr_status_id: "confirmed",
          job_bsp_status_id: "confirmed",
          employee_id: employee_id,
          ticket_no: ticket_number
        } = job,
        _params
      )
      when employee_id != nil do
    #    ==================  create job Notifications for CMR ============================
    %{user_id: employee_user_id, branch_id: branch_id} = Employees.get_employee(employee_id)
    %{user_id: owner_user_id} = BSP.get_business_by_employee_id(employee_id)

    %{profile: %{"first_name" => first_name, "last_name" => last_name}} =
      Accounts.get_user!(job.inserted_by)

    %{language: _, name: emp_name} = make_notification_data(employee_user_id)

    %{profile: %{"first_name" => bsp_first_name, "last_name" => bsp_last_name}} =
      Accounts.get_user!(owner_user_id)

    params = %{
      service_type: job.service_type_id,
      job_id: job.id,
      emp_profile_name: emp_name,
      ticket_number: ticket_number,
      bsp_profile_name: "#{bsp_first_name} #{bsp_last_name}",
      cmr_profile_name: "#{first_name} #{last_name}"
    }

    sends_notification(job.inserted_by, "cmr", params, "create_job_confirmed_for_cmr")
    sends_email(job.id, job.inserted_by, "create_job_confirmed_for_cmr")
    #   ==================  create job Notification for BSP ============================
    params = Map.merge(params, %{branch_id: branch_id})

    if employee_user_id == owner_user_id do
      sends_notification(owner_user_id, "bsp", params, "create_job_confirmed_for_bsp")
      sends_email(job.id, owner_user_id, "create_job_confirmed_for_bsp")
    else
      sends_notification(owner_user_id, "bsp", params, "create_job_confirmed_for_bsp")
      sends_notification(employee_user_id, "emp", params, "create_job_confirmed_for_bsp")
      sends_email(job.id, owner_user_id, "create_job_confirmed_for_bsp")
      sends_email(job.id, employee_user_id, "create_job_confirmed_for_bsp")
    end

    {:ok, ["notification sent!"]}
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      {:ok, ["Something went wrong, can't send notification"]}
  end

  #  create job (pending)
  def send_notification_for_create_job(
        %{
          employee_id: employee_id,
          job_cmr_status_id: "pending",
          job_bsp_status_id: "pending",
          ticket_no: ticket_number
        } = job,
        _params
      )
      when employee_id != nil do
    #    ==================  create job Notifications for CMR ============================
    %{user_id: employee_user_id, branch_id: branch_id} = Employees.get_employee(employee_id)
    %{user_id: owner_user_id} = BSP.get_business_by_employee_id(employee_id)

    %{profile: %{"first_name" => first_name, "last_name" => last_name}} =
      Accounts.get_user!(job.inserted_by)

    %{language: _, name: emp_name} = make_notification_data(employee_user_id)

    %{profile: %{"first_name" => bsp_first_name, "last_name" => bsp_last_name}} =
      Accounts.get_user!(owner_user_id)

    params = %{
      service_type: job.service_type_id,
      job_id: job.id,
      emp_profile_name: emp_name,
      ticket_number: ticket_number,
      bsp_profile_name: "#{bsp_first_name} #{bsp_last_name}",
      cmr_profile_name: "#{first_name} #{last_name}"
    }

    sends_notification(job.inserted_by, "cmr", params, "create_job_pending_for_cmr")
    sends_email(job.id, job.inserted_by, "create_job_pending_for_cmr")

    params = Map.merge(params, %{branch_id: branch_id})
    #       ==================  create job Notification for BSP============================
    if employee_user_id == owner_user_id do
      sends_notification(owner_user_id, "bsp", params, "create_job_pending_for_bsp")
      sends_email(job.id, owner_user_id, "create_job_pending_for_cmr")
    else
      sends_notification(owner_user_id, "bsp", params, "create_job_pending_for_bsp")
      sends_notification(employee_user_id, "emp", params, "create_job_pending_for_bsp")
      sends_email(job.id, owner_user_id, "create_job_pending_for_cmr")
      sends_email(job.id, employee_user_id, "create_job_pending_for_cmr")
    end

    {:ok, ["notification sent!"]}
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      {:ok, ["Something went wrong, can't send notification"]}
  end

  #  create job (pending)
  def send_notification_for_create_job(
        %{
          branch_service_id: bs_id,
          job_cmr_status_id: "pending",
          job_bsp_status_id: "pending",
          ticket_no: ticket_number
        } = job,
        _params
      ) do
    #    ==================  create job Notifications for CMR ============================
    %{id: branch_id, business_id: business_id} = BSP.get_branch_by_branch_service(bs_id)
    %{user_id: owner_user_id} = BSP.get_business(business_id)

    %{profile: %{"first_name" => first_name, "last_name" => last_name}} =
      Accounts.get_user!(job.inserted_by)

    %{language: _, name: owner_name} = make_notification_data(owner_user_id)

    params = %{
      service_type: job.service_type_id,
      job_id: job.id,
      emp_profile_name: owner_name,
      ticket_number: ticket_number,
      bsp_profile_name: owner_name,
      cmr_profile_name: "#{first_name} #{last_name}"
    }

    sends_notification(job.inserted_by, "cmr", params, "create_job_pending_for_cmr")
    sends_email(job.id, job.inserted_by, "create_job_pending_for_cmr")

    params = Map.merge(params, %{branch_id: branch_id})
    #       ==================  create job Notification for BSP============================
    sends_notification(owner_user_id, "bsp", params, "create_job_pending_for_bsp")
    sends_email(job.id, owner_user_id, "create_job_pending_for_cmr")
    {:ok, ["notification sent!"]}
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      {:ok, ["Something went wrong, can't send notification"]}
  end

  def send_notification_for_create_job(_job, _params) do
    {:ok, ["can't send notifications on creating job"]}
  end

  #   ================== specific for Agent Re assign ============================
  def send_notification_for_update_job(
        %{employee_id: previous_employee_id} = _previous_job,
        %{
          id: job_id,
          inserted_by: cmr_id,
          service_type_id: service_type,
          ticket_no: ticket_number
        } = _job,
        %{employee_id: current_employee_id} = _params
      ) do
    %{user_id: employee_user_id, branch_id: branch_id} =
      Employees.get_employee(current_employee_id)

    %{user_id: owner_user_id} = BSP.get_business_by_employee_id(current_employee_id)

    params = %{
      service_type: service_type,
      job_id: job_id,
      branch_id: branch_id,
      ticket_number: ticket_number,
      current_employee_id: current_employee_id,
      previous_employee_id: previous_employee_id
    }

    #   ==================  Agent Reassign job Notification for CMR ============================
    sends_notification(cmr_id, "cmr", params, "agent_reassign_job_for_cmr")

    #   ==================  Agent Reassign job Notification for BSP ============================
    if employee_user_id == owner_user_id do
      sends_notification(owner_user_id, "bsp", params, "agent_reassign_job_for_bsp_emp")
    else
      sends_notification(owner_user_id, "bsp", params, "agent_reassign_job_for_bsp_emp")
      sends_notification(employee_user_id, "emp", params, "agent_reassign_job_for_bsp_emp")
    end

    {:ok, ["notification sent!"]}
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      {:ok, ["Something went wrong, can't send notification"]}
  end

  #  ============= Dispute Resolved ================
  def send_notification_for_update_job(
        %{job_cmr_status_id: "dispute"} = _previous_job,
        %{
          id: job_id,
          employee_id: employee_id,
          inserted_by: cmr_id,
          service_type_id: service_type,
          ticket_no: ticket_number
        } = _job,
        _params
      ) do
    %{id: business_id} = BSP.get_business_by_employee_id(employee_id)

    [%{final_amount: amount}] =
      Invoices.get_invoice_by_job(%{job_id: job_id, business_id: business_id})

    params = %{
      service_type: service_type,
      job_id: job_id,
      invoice_amount: amount,
      branch_id: nil,
      ticket_number: ticket_number
    }

    sends_notification(cmr_id, "cmr", params, "manage_dispute_for_cmr")
    sends_email(job_id, cmr_id, "manage_dispute_for_cmr", true, true)
    {:ok, ["notification sent!"]}
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      {:ok, ["Something went wrong, can't send notification"]}
  end

  #  when needed to send notifications and emails to both CMR and BSP
  def send_notification_for_update_job(
        %{job_cmr_status_id: prev_job_cmr_status_id, job_bsp_status_id: prev_job_bsp_status_id} =
          _previous_job,
        %{
          employee_id: employee_id,
          id: job_id,
          inserted_by: cmr_id,
          service_type_id: service_type,
          ticket_no: ticket_number
        } = _job,
        %{job_cmr_status_id: job_cmr_status_id, job_bsp_status_id: job_bsp_status_id} = _params
      )
      when employee_id != nil do
    send_cmr_notifications(%{
      employee_id: employee_id,
      job_id: job_id,
      cmr_id: cmr_id,
      service_type: service_type,
      prev_job_cmr_status_id: prev_job_cmr_status_id,
      job_cmr_status_id: job_cmr_status_id,
      job_bsp_status_id: job_bsp_status_id,
      ticket_number: ticket_number
    })

    send_bsp_notifications(%{
      employee_id: employee_id,
      job_id: job_id,
      cmr_id: cmr_id,
      service_type: service_type,
      prev_job_bsp_status_id: prev_job_bsp_status_id,
      job_bsp_status_id: job_bsp_status_id,
      job_cmr_status_id: job_cmr_status_id,
      ticket_number: ticket_number
    })

    {:ok, ["notification send to CMR and BSP"]}
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      {:ok, ["can't send cmr and bsp notification!"]}
  end

  #  when needed to send notifications and emails to CMR
  def send_notification_for_update_job(
        %{job_cmr_status_id: prev_job_cmr_status_id} = _previous_job,
        %{
          employee_id: employee_id,
          id: job_id,
          inserted_by: cmr_id,
          service_type_id: service_type,
          ticket_no: ticket_number
        } = _job,
        %{job_cmr_status_id: job_cmr_status_id} = params
      )
      when employee_id != nil do
    send_cmr_notifications(%{
      employee_id: employee_id,
      job_id: job_id,
      cmr_id: cmr_id,
      service_type: service_type,
      prev_job_cmr_status_id: prev_job_cmr_status_id,
      job_cmr_status_id: job_cmr_status_id,
      job_bsp_status_id: params[:job_bsp_status_id],
      ticket_number: ticket_number
    })

    {:ok, ["notification sent to CMR"]}
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      {:ok, ["can't send cmr notification!"]}
  end

  #  when needed to send notifications and emails to BSP
  def send_notification_for_update_job(
        %{job_bsp_status_id: prev_job_bsp_status_id} = _previous_job,
        %{
          employee_id: employee_id,
          id: job_id,
          inserted_by: cmr_id,
          service_type_id: service_type,
          ticket_no: ticket_number
        } = _job,
        %{job_bsp_status_id: job_bsp_status_id} = params
      )
      when employee_id != nil do
    send_bsp_notifications(%{
      employee_id: employee_id,
      job_id: job_id,
      cmr_id: cmr_id,
      service_type: service_type,
      prev_job_bsp_status_id: prev_job_bsp_status_id,
      job_bsp_status_id: job_bsp_status_id,
      job_cmr_status_id: params[:job_cmr_status_id],
      ticket_number: ticket_number
    })

    {:ok, ["notification sent to BSP"]}
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      {:ok, ["can't send bsp notification!"]}
  end

  def send_notification_for_update_job(_previous_job, _job, _params) do
    {:ok, ["can't call notifications function!"]}
  end

  #           notifications and emails for cmr
  def send_cmr_notifications(%{
        employee_id: employee_id,
        job_id: job_id,
        cmr_id: cmr_id,
        service_type: service_type,
        job_bsp_status_id: job_bsp_status_id,
        job_cmr_status_id: job_cmr_status_id,
        ticket_number: ticket_number
      }) do
    params = %{service_type: service_type, job_id: job_id, ticket_number: ticket_number}
    %{name: bsp_branch_profile_name} = BSP.get_branch_by_employee_id(employee_id)

    amount =
      case Payments.get_payment_by_job_id(job_id) do
        [%{total_transaction_amount: amount} | _] -> amount
        _ -> nil
      end

    cond do
      #   ==================  Accept changes  ============================
      job_bsp_status_id == "accept" ->
        sends_notification(cmr_id, "cmr", params, "accept_job_for_cmr")
        sends_email(job_id, cmr_id, "accept_job_changes_for_bsp")

      #   ==================  Reject changes ============================
      job_bsp_status_id == "reject" ->
        sends_notification(cmr_id, "cmr", params, "reject_job_for_cmr")
        sends_email(job_id, cmr_id, "reject_job_changes_for_bsp")

      #   ==================  Cancelled ============================
      job_cmr_status_id == "cancelled" ->
        sends_notification(cmr_id, "cmr", params, "cancel_job_for_cmr")
        sends_email(job_id, cmr_id, "cancel_job_for_cmr")

      #   ==================  Re schedule ============================
      job_cmr_status_id == "accept_reject" ->
        Map.merge(params, %{bsp_branch_profile_name: bsp_branch_profile_name})
        sends_notification(cmr_id, "cmr", params, "reschedule_job_for_cmr")
        sends_email(job_id, cmr_id, "reschedule_job_for_cmr")

      #   ==================  On Boards ============================
      job_cmr_status_id == "on_board" ->
        params = Map.merge(params, %{cmr_id: cmr_id, employee_id: employee_id})

        if service_type == "walk_in" do
          sends_notification(cmr_id, "cmr", params, "on_board_walk_in_cmr_near_appointment")
        else
          sends_notification(cmr_id, "cmr", params, "in_home_on_demand_bsp_near_appointment")
        end

      #   ==================  Invoice Ready ============================
      job_cmr_status_id == "invoiced" ->
        params = Map.merge(params, %{invoice_amount: amount})
        sends_notification(cmr_id, "cmr", params, "invoice_ready_for_cmr")
        sends_email(job_id, cmr_id, "invoice_ready_for_cmr", true, true)

      #   ==================  Payment made ============================
      job_cmr_status_id == "paid" ->
        params = Map.merge(params, %{invoice_amount: amount})
        sends_notification(cmr_id, "cmr", params, "payment_made")
        sends_email(job_id, cmr_id, "payment_made", "cmr", true, true)

      #   ==================  Invoice Adjusted for CMR ============================
      job_cmr_status_id == "adjusted" ->
        params = Map.merge(params, %{invoice_amount: amount})
        sends_notification(cmr_id, "cmr", params, "adjusted_invoice_for_cmr")
        sends_email(job_id, cmr_id, "adjusted_invoice_for_cmr", true, true)

      true ->
        "no condition matched to send cmr notification!"
    end
  end

  #       bsp notifications and Emails
  def send_bsp_notifications(%{
        employee_id: employee_id,
        job_id: job_id,
        cmr_id: cmr_id,
        service_type: service_type,
        job_cmr_status_id: job_cmr_status_id,
        job_bsp_status_id: job_bsp_status_id,
        ticket_number: ticket_number
      }) do
    %{user_id: employee_user_id, branch_id: branch_id} = Employees.get_employee(employee_id)

    params = %{
      job_id: job_id,
      service_type: service_type,
      branch_id: branch_id,
      ticket_number: ticket_number
    }

    %{user_id: owner_user_id} = BSP.get_business_by_employee_id(employee_id)
    %{name: bsp_branch_profile_name} = BSP.get_branch_by_employee_id(employee_id)

    amount =
      case Payments.get_payment_by_job_id(job_id) do
        [%{invoice_amount: amount} | _] -> amount
        _ -> nil
      end

    cond do
      #   ==================  Accept changes  ============================
      job_cmr_status_id == "accept" ->
        if employee_user_id == owner_user_id do
          sends_notification(owner_user_id, "bsp", params, "accept_job_changes_for_bsp")
          sends_email(job_id, owner_user_id, "accept_job_changes_for_bsp")
        else
          sends_notification(owner_user_id, "bsp", params, "accept_job_changes_for_bsp")
          sends_notification(employee_user_id, "emp", params, "accept_job_changes_for_bsp")
          sends_email(job_id, owner_user_id, "accept_job_changes_for_bsp")
          sends_email(job_id, employee_user_id, "accept_job_changes_for_bsp")
        end

      #   ==================  Reject changes  ============================
      job_cmr_status_id == "reject" ->
        if employee_user_id == owner_user_id do
          sends_notification(owner_user_id, "bsp", params, "reject_job_changes_for_bsp")
          sends_email(job_id, owner_user_id, "reject_job_changes_for_bsp")
        else
          sends_notification(owner_user_id, "bsp", params, "reject_job_changes_for_bsp")
          sends_notification(employee_user_id, "emp", params, "reject_job_changes_for_bsp")
          sends_email(job_id, owner_user_id, "reject_job_changes_for_bsp")
          sends_email(job_id, employee_user_id, "reject_job_changes_for_bsp")
        end

      #   ==================  Cancelled  ============================
      job_bsp_status_id == "cancelled" ->
        if employee_user_id == owner_user_id do
          sends_notification(owner_user_id, "bsp", params, "cancel_job_for_bsp")
          sends_email(job_id, owner_user_id, "cancel_job_for_bsp")
        else
          sends_notification(owner_user_id, "bsp", params, "cancel_job_for_bsp")
          sends_notification(employee_user_id, "emp", params, "cancel_job_for_bsp")
          sends_email(job_id, owner_user_id, "cancel_job_for_bsp")
          sends_email(job_id, employee_user_id, "cancel_job_for_bsp")
        end

      #   ==================  Re schedule  ============================
      job_bsp_status_id == "accept_reject" ->
        params = Map.merge(params, %{bsp_branch_profile_name: bsp_branch_profile_name})

        if employee_user_id == owner_user_id do
          sends_notification(owner_user_id, "bsp", params, "reschedule_job_for_bsp")
          sends_email(job_id, owner_user_id, "reschedule_job_for_bsp")
        else
          sends_notification(owner_user_id, "bsp", params, "reschedule_job_for_bsp")
          sends_notification(employee_user_id, "emp", params, "reschedule_job_for_bsp")
          sends_email(job_id, owner_user_id, "reschedule_job_for_bsp")
          sends_email(job_id, employee_user_id, "reschedule_job_for_bsp")
        end

      #   ==================  On Boards ============================
      job_bsp_status_id == "on_board" ->
        params = Map.merge(params, %{cmr_id: cmr_id, employee_id: employee_id})

        if employee_user_id == owner_user_id do
          if service_type == "walk_in" do
            sends_notification(owner_user_id, "bsp", params, "bsp_on_boards_appointment")
          else
            sends_notification(
              owner_user_id,
              "bsp",
              params,
              "in_home_on_demand_bsp_near_appointment_cmr_bsp_initiates_on_board_action"
            )
          end
        else
          if service_type == "walk_in" do
            sends_notification(owner_user_id, "bsp", params, "bsp_on_boards_appointment")
          else
            sends_notification(
              owner_user_id,
              "bsp",
              params,
              "in_home_on_demand_bsp_near_appointment_cmr_bsp_initiates_on_board_action"
            )
          end

          if service_type == "walk_in" do
            sends_notification(owner_user_id, "bsp", params, "bsp_on_boards_appointment")
          else
            sends_notification(
              employee_user_id,
              "emp",
              params,
              "in_home_on_demand_bsp_near_appointment_cmr_bsp_initiates_on_board_action"
            )
          end
        end

      #   ==================  Raise Dispute  ============================
      job_bsp_status_id == "dispute" ->
        params = Map.merge(params, %{invoice_amount: amount})

        if employee_user_id == owner_user_id do
          sends_notification(owner_user_id, "bsp", params, "raise_dispute_for_bsp")
          sends_email(job_id, owner_user_id, "raise_dispute_for_bsp", true)
        else
          sends_notification(owner_user_id, "bsp", params, "raise_dispute_for_bsp")
          sends_notification(employee_user_id, "emp", params, "raise_dispute_for_bsp")
          sends_email(job_id, owner_user_id, "raise_dispute_for_bsp", true)
          sends_email(job_id, employee_user_id, "raise_dispute_for_bsp", true)
        end

      #   ==================  Payment made  ============================
      job_bsp_status_id == "paid" ->
        params = Map.merge(params, %{invoice_amount: amount})

        if employee_user_id == owner_user_id do
          sends_notification(owner_user_id, "bsp", params, "payment_made")
          sends_email(job_id, owner_user_id, "payment_made", "bsp", true)
        else
          sends_notification(owner_user_id, "bsp", params, "payment_made")
          sends_notification(employee_user_id, "emp", params, "payment_made")
          sends_email(job_id, owner_user_id, "payment_made", "bsp", true)
          sends_email(job_id, employee_user_id, "payment_made", "bsp", true)
        end

      #   ==================  Invoice Adjust request for EMP ============================
      job_bsp_status_id == "adjust_invoice" ->
        params = Map.merge(params, %{invoice_amount: amount})

        if employee_user_id == owner_user_id do
          sends_notification(owner_user_id, "bsp", params, "adjust_invoice_for_bsp")
          sends_email(job_id, owner_user_id, "adjust_invoice_for_bsp", true)
        else
          sends_notification(owner_user_id, "bsp", params, "adjust_invoice_for_bsp")
          sends_notification(employee_user_id, "emp", params, "adjust_invoice_for_bsp")
          sends_email(job_id, owner_user_id, "adjust_invoice_for_bsp", true)
          sends_email(job_id, employee_user_id, "adjust_invoice_for_bsp", true)
        end

      true ->
        "no condition matched for bsp emp notification!"
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      {:ok, [""]}
  end

  def sends_notification(user_id, role, params, purpose) do
    %{language: language} = make_notification_data(user_id)

    {:ok, _notif_job_id} =
      Exq.enqueue_in(
        Exq,
        "default",
        3,
        "CoreWeb.Workers.NotifyWorker",
        [
          purpose,
          user_id,
          language,
          role,
          params
        ]
      )
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      {:ok, "notification crashed"}
  end

  def sends_email(
        job_id,
        cmr_id,
        purpose,
        role \\ "cmr",
        invoice_attrs \\ false,
        cmr_paid_amount \\ false
      ) do
    attrs =
      if invoice_attrs do
        make_attributes_for_email(job_id, cmr_id)
        |> Map.merge(make_invoice_attributes_for_email(job_id, cmr_paid_amount))
      else
        make_attributes_for_email(job_id, cmr_id)
      end

    {:ok, _cmr_email_job_id} =
      Exq.enqueue(
        Exq,
        "default",
        "CoreWeb.Workers.NotificationEmailsWorker",
        [
          purpose,
          attrs,
          role
        ]
      )
  end

  def send_notification_for_bsp(%{branch_id: branch_id} = params, purpose) do
    bsp_user_id =
      case Employees.get_active_employee_by_role_and_branch(branch_id, "branch_manager") do
        [%{user_id: user_id} | _] ->
          user_id

        _ ->
          case Employees.get_active_employee_by_role_and_branch(branch_id, "owner") do
            [%{user_id: user_id} | _] -> user_id
            _ -> nil
          end
      end

    owner_user_id =
      case BSP.get_business_by_branch_id(branch_id) do
        %{user_id: user_id} -> user_id
        _ -> nil
      end

    if not is_nil(bsp_user_id) and not is_nil(owner_user_id) and owner_user_id == bsp_user_id do
      sends_notification(owner_user_id, "bsp", params, purpose)
    else
      if not is_nil(owner_user_id), do: sends_notification(owner_user_id, "bsp", params, purpose)
      if not is_nil(bsp_user_id), do: sends_notification(bsp_user_id, "bsp", params, purpose)
    end
  end

  def send_notification_for_invite_employee(
        %{
          user: cmr,
          employee: %{
            contract_begin_date: contract_begin_date,
            employee_role_id: employee_role_id
          }
        },
        branch_id
      ) do
    %{name: business_name} = BSP.get_business_by_branch_id(branch_id)
    #    ==================  cmr ============================
    %{language: language, name: _cmr_name} =
      Core.Jobs.JobNotificationHandler.make_notification_data(cmr.id)

    {:ok, _cmr_notif_job_id} =
      Exq.enqueue_in(
        Exq,
        "default",
        3,
        "CoreWeb.Workers.NotifyWorker",
        [
          "bsp_sends_employment_invitation_to_cmr",
          cmr.id,
          language,
          "cmr",
          %{bsp_profile_name: business_name}
        ]
      )

    params =
      case Core.Accounts.get_user!(cmr.id) do
        %{
          gender: gender,
          profile: %{"first_name" => cmr_first_name, "last_name" => cmr_last_name}
        } ->
          gender =
            if is_binary(gender) do
              cond do
                String.contains?(gender, ["male", "Male", "MALE"]) -> "Mr."
                String.contains?(gender, ["female", "Female", "FEMALE"]) -> "Ms."
                true -> ""
              end
            else
              ""
            end

          %{gender: gender, cmr_first_name: cmr_first_name, cmr_last_name: cmr_last_name}

        _ ->
          %{gender: "", cmr_first_name: "", cmr_last_name: ""}
      end

    bsp_profile =
      case BSP.get_branch!(branch_id) do
        %{} = branch -> %{name: branch.name, id: branch.id}
        _ -> ""
      end

    employee_role =
      case Employees.get_employee_role(employee_role_id) do
        %{name: name} -> name
        _ -> ""
      end

    contract_begin_date =
      DT.convert_utc_time_to_local_time(contract_begin_date)
      |> DT.reformat_datetime_for_emails()

    {year, _, _} = Date.utc_today() |> Date.to_erl()

    attrs =
      Map.merge(params, %{
        email: cmr.email,
        language: language,
        year: year,
        bsp_branch_profile_name: bsp_profile.name,
        contract_begin_date: contract_begin_date,
        employee_role: employee_role,
        branch_id: bsp_profile.id
      })

    {:ok, _cmr_email_job_id} =
      Exq.enqueue(
        Exq,
        "default",
        "CoreWeb.Workers.NotificationEmailsWorker",
        [
          "invite_employee",
          attrs,
          "cmr"
        ]
      )

    {:ok, ["notification sent!"]}
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      {:ok, ["Something went wrong, can't send notification"]}
  end
end
