defmodule Crm.Plugs.RequireAuth do
  use CrmWeb, :controller

  def init(_params) do
  end

  def call(conn, _params) do
    if conn.assigns[:user] do
      conn
    else
      conn
      |> put_flash(:error, "Please Login First")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end
