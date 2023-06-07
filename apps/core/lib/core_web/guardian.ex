defmodule CoreWeb.Guardian do
  @moduledoc false
  use Guardian, otp_app: :core

  def subject_for_token(%Core.Schemas.User{} = user, _claims) do
    # You can use any value for the subject of your token but
    # it should be useful in retrieving the resource later, see
    # how it being used on `resource_from_claims/1` function.
    # A unique `id` is a good subject, a non-unique email address
    # is a poor subject.
    {:ok, to_string(user.id)}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(claims) do
    # Here we'll look up our resource from the claims, the subject can be
    # found in the `"sub"` key. In `above subject_for_token/2` we returned
    # the resource id so here we'll rely on that to look it up.
    case Core.Accounts.get_user!(claims["sub"]) do
      nil -> {:error, :reason_for_error}
      user -> {:ok, user}
    end
  end

  #  for Guardian DB
  @spec after_encode_and_sign(any(), map(), binary(), any()) :: {:ok, binary()}
  def after_encode_and_sign(resource, claims, token, _options) do
    claims = Map.merge(claims, %{"sub" => to_string(claims["sub"])})

    with {:ok, _} <- Guardian.DB.after_encode_and_sign(resource, claims["typ"], claims, token) do
      {:ok, token}
    end
  end

  @spec on_verify(map(), binary(), any()) :: {:ok, map()}
  def on_verify(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_verify(claims, token) do
      {:ok, claims}
    end
  end

  @spec on_refresh(binary(), binary()) :: {:ok, binary()}
  def on_refresh(old_token, new_token) do
    with {:ok, _} <- Guardian.DB.on_refresh(old_token, new_token) do
      {:ok, new_token}
    end
  end

  @spec on_revoke(map(), binary(), any()) :: {:ok, map()}
  def on_revoke(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_revoke(claims, token) do
      {:ok, claims}
    end
  end
end
