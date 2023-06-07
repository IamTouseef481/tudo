defmodule CoreWeb.Utils.HttpRequest do
  @moduledoc """
  This Module is for http requests to 3rd party api's
  """
  import CoreWeb.Utils.Errors

  def post(url, input, headers, options) do
    body = Poison.encode!(input)

    if false == is_nil(url) do
      case HTTPoison.post(url, body, headers, options) do
        {:ok, data} ->
          case Poison.decode(data.body) do
            {:ok, %{"data" => %{"token" => token}}} ->
              {:ok, token}

            {:ok, %{"message" => message, "status" => "SUCCESS", "subCode" => "200"} = _data} ->
              {:ok, message}

            {:ok, %{"message" => _, "details" => [%{"description" => error} | _]} = _data} ->
              {:error, error}

            {:ok, %{"message" => message, "status" => "OK"} = _data} ->
              {:ok, message}

            {:ok, %{"message" => message, "status" => "SUCSUCCESSCESS"} = _data} ->
              {:ok, message}

            {:ok, %{"error_description" => error}} ->
              {:error, error}

            {:ok, %{"message" => error}} ->
              {:error, error}

            {:ok, %{"links" => _links} = data} ->
              {:ok, data}

            {:ok, %{"id" => _} = data} ->
              {:ok, data}

            {:ok, %{"order_id" => _order_id}} = data ->
              data

            {:ok, %{"cf_payment_id" => _cf_payment_id}} = data ->
              data

            {:ok, %{"error" => %{"message" => message}}} ->
              {:ok, message}

            {:ok, %{"error" => message}} ->
              {:error, message}

            {:ok, data} ->
              {:ok, data}

            {:error, :invalid, 0} ->
              {:error, :invalid, ["No Response from API or inavlid Request"]}

            exception ->
              logger(
                __MODULE__,
                exception,
                ["No Case clause matching in HTTP.POST"],
                __ENV__.line
              )
          end

        exception ->
          logger(__MODULE__, exception, ["HTTP Error, Something went wrong"], __ENV__.line)
      end
    else
      {:error, ["URL for request not supplied"]}
    end
  end

  def get(url, headers, options) do
    case HTTPoison.get(url, headers, options) do
      {:ok, data} ->
        case Poison.decode(data.body) do
          {:ok, %{"rows" => rows}} ->
            {:ok, rows}

          {:ok, %{"message" => _, "details" => [%{"description" => error} | _]} = _data} ->
            {:error, error}

          {:ok, %{"error_description" => error}} ->
            {:error, error}

          {:ok, %{"message" => error}} ->
            {:error, error}

          {:ok, %{"links" => _links} = data} ->
            {:ok, data}

          {:ok, data} when is_map(data) ->
            {:ok, data}

          exception ->
            logger(__MODULE__, exception, ["No Case CLause matching in HTTP.POST"], __ENV__.line)
        end

      exception ->
        logger(__MODULE__, exception, ["HTTP Error, Something went wrong"], __ENV__.line)
    end
  end

  def put(url, input, headers, options) do
    body = Poison.encode!(input)

    if false == is_nil(url) do
      case HTTPoison.put(url, body, headers, options) do
        {:ok, %{body: ""}} ->
          {:ok, %{}}

        {:ok, %{body: body}} ->
          case Poison.decode(body) do
            {:ok, data} -> {:ok, data}
            {:error, error} -> {:error, error}
          end

        exception ->
          logger(__MODULE__, exception, ["HTTP Error, Something went wrong"], __ENV__.line)
      end
    else
      {:error, ["URL for request not supplied"]}
    end
  end

  def patch(url, input, headers, options) do
    body = Poison.encode!(input)

    if false == is_nil(url) do
      case HTTPoison.patch(url, body, headers, options) do
        {:ok, %{body: ""}} ->
          {:ok, %{}}

        {:ok, %{body: body}} ->
          case Poison.decode(body) do
            {:ok, data} -> {:ok, data}
            {:error, error} -> {:error, error}
          end

        exception ->
          logger(__MODULE__, exception, ["HTTP Error, Something went wrong"], __ENV__.line)
      end
    else
      {:error, ["URL for request not supplied"]}
    end
  end

  def delete(url, headers, options) do
    if false == is_nil(url) do
      case HTTPoison.delete(url, headers, options) do
        {:ok, %{body: ""}} ->
          {:ok, %{}}

        {:ok, %{body: body}} ->
          case Poison.decode(body) do
            {:ok, data} -> {:ok, data}
            {:error, error} -> {:error, error}
          end

        exception ->
          logger(__MODULE__, exception, ["HTTP Error, Something went wrong"], __ENV__.line)
      end
    else
      {:error, ["URL for request not supplied"]}
    end
  end
end
