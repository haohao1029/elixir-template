defmodule CrmWeb.AuthController do
  use CrmWeb, :controller
  plug Ueberauth

  alias Crm.User
  alias Crm.Repo
  alias Crm.Accounts
  def new(conn, _params) do
    changeset = User.changeset(%User{}, %{})
    render(conn, "new.html", changeset: changeset)
  end
  def login(conn, _params) do
    changeset = User.changeset(%User{}, %{})

    render(conn, "login.html", changeset: changeset)
  end
  def session(conn, %{"session" => %{"email" => email, "password" => password}}) do
    encrypt_pass = :crypto.hash(:sha512, password)
    |> Base.encode16
    |> String.downcase

    case Accounts.sign_in(email, encrypt_pass) do
      {:ok, user} ->
        IO.inspect(conn)
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "You have successfully signed in!")
        |> redirect(to: Routes.item_path(conn, :index))
      {:error, _params} ->
        conn
        |> put_flash(:error, "Invalid Email or Password")
        |> redirect(to: Routes.auth_path(conn, :login))
    end
  end
  def create(conn, %{"user" => user}) do
    encrypt_pass = :crypto.hash(:sha512, user["password"])
    |> Base.encode16
    |> String.downcase

    user = Map.put(user, "encrypt_pass", encrypt_pass) |> Map.delete("password")
    changeset = User.changeset(%User{}, user)
    case Repo.insert(changeset) do
      {:ok, _user} ->
        put_flash(conn, :info, "You have successfully signed up!")
        redirect(conn, to: Routes.auth_path(conn, :login))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_params = %{
      token: auth.credentials.token,
      email: auth.info.email,
      provider: Atom.to_string(auth.provider)
    }
    changeset = User.changeset(%User{}, user_params)

    signin(conn, changeset)
  end

  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: Routes.page_path(conn, :index))
  end

  defp signin(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user} ->
        if user.is_admin == true do
          conn
          |> put_flash(:info, "Admin WC back")
          |> put_session(:user_id, user.id)
          |> put_session(:user_admin, user.is_admin)
          |> redirect(to: Routes.page_path(conn, :index))
        else
          conn
          |> put_flash(:info, "WC back")
          |> put_session(:user_id, user.id)
          |> redirect(to: Routes.page_path(conn, :index))
        end

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error sign in")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  defp insert_or_update_user(changeset) do
    IO.inspect(changeset)

    case Repo.get_by(User, email: changeset.changes.email) do
      nil ->
        Repo.insert(changeset)

      user ->
        {:ok, user}
    end
  end
end
