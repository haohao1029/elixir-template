    create table(:users) do
      add :email, :string
      add :provider, :string
      add :token, :string
      add :password, :binary
      add :is_admin, :boolean, default: false, null: false
      timestamps()
    end
    create unique_index(:users, [:email])
