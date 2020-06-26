defmodule Crm.User do
  use Ecto.Schema
  import Ecto.Changeset
  @derive {Jason.Encoder, only: [:email, :provider, :is_admin]}

  schema "users" do
    field :email, :string
    field :provider, :string
    field :token, :string
    field :is_admin, :boolean, default: false, null: false
    field :password, :binary

    timestamps()
  end

  @spec changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:password, :email, :provider, :token, :is_admin])
    |> validate_required([:email])
  end
end
