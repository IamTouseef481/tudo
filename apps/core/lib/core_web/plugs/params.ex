defmodule CoreWeb.Plugs.Params do
  @moduledoc false
  import CoreWeb.Utils.Errors

  def init(default), do: default

  def call(conn, _default) do
    set_utc_difference(conn.query_params)
    #    Application.get_env(:core, :utc_difference)
    set_page_size_for_pagination(conn.query_params)
    #    Application.get_env(:core, :page_size)
    set_page_number_for_pagination(conn.query_params)
    #    Application.get_env(:core, :page_number)
    set_mail_subject(conn.host)
    #    Application.get_env(:core, :application)
    set_application_name(conn.query_params)
    conn
  end

  def set_mail_subject(host), do: Application.put_env(:core, :identify_host_url, host)

  def set_utc_difference(query_params) do
    case query_params["utc_difference"] do
      nil ->
        Application.put_env(:core, :utc_difference, 0)

      dif ->
        dif = String.to_integer(dif)
        Application.put_env(:core, :utc_difference, dif)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      logger(__MODULE__, query_params, :info, __ENV__.line)
      Application.put_env(:core, :utc_difference, 0)
  end

  def set_page_size_for_pagination(query_params) do
    case query_params["page_size"] do
      nil ->
        Application.put_env(:core, :page_size, nil)

      size ->
        size = String.to_integer(size)
        Application.put_env(:core, :page_size, size)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      Application.put_env(:core, :page_size, nil)
  end

  def set_page_number_for_pagination(query_params) do
    case query_params["page_number"] do
      nil ->
        Application.put_env(:core, :page_number, nil)

      page_number ->
        page_number = String.to_integer(page_number)
        Application.put_env(:core, :page_number, page_number)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      Application.put_env(:core, :page_number, nil)
  end

  def set_application_name(query_params) do
    case query_params["application"] do
      nil ->
        Application.put_env(:core, :application_name, nil)

      application_name ->
        Application.put_env(:core, :application_name, application_name)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      Application.put_env(:core, :application_name, nil)
  end
end
