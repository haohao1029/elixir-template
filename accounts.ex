defmodule Crm.Accounts do
  import Ecto.Query, warn: false
  alias Crm.Repo
  alias Crm.User

  def list_users do
    Repo.all(User)
  end
  def sign_in(email, password) do
    user = Repo.all(from u in User,where: u.email == ^email)
    IO.inspect(user)
    cond do
      user != [] ->
        if hd(user).encrypt_pass == password do
          {:ok, hd(user)}
        else
          {:error, :unauthorized}
        end
        true ->
          {:error, :unauthorized}
    end
  end

end
