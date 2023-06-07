defmodule Core.Repo.Migrations.AddUserReferralCodes do
  use Ecto.Migration

  import Ecto.Query, warn: false

  alias Core.{Context, Repo}
  alias Core.Schemas.User

  def change do
    users = from(u in User, where: is_nil(u.referral_code)) |> Repo.all()

    Enum.each(
      users,
      fn user ->
        ref_code = CoreWeb.Utils.String.string_of_length()
        Context.update(User, user, %{referral_code: ref_code})
      end
    )

    flush()
  end
end
