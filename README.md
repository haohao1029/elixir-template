# elixir-template

#mix.exs


defp deps do
      {:ueberauth, "~> 0.6"},
     {:ueberauth_github, "~> 0.7"},
      {:ueberauth_facebook, "~> 0.8"}

end

#config.exs

 config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [default_scope: "user, public_repo"]},
    facebook: {Ueberauth.Strategy.Facebook, []}
    ]

 config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: "8e462b4c6ea982794256",
  client_secret: "8cf2095086f00c288b44f9b3e5962c2aadf1dee8"

 config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: "265816891523856",
  client_secret: "660fc9f113d0b4bc306c9741aeed75fd"

#router.ex


pipeline :browser do
    plug Crm.Plugs.SetUser
end



  scope "/auth", CrmWeb do
    pipe_through :browser
    get "/new", AuthController, :new
    get "/login", AuthController, :login
    post "/", AuthController, :create
    post "/session", AuthController, :session

    get "/signout", AuthController, :signout
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end
  
  
  
  
  #migration
  
   create table(:users) do
   add :email, :string
    add :provider, :string
    add :token, :string
    add :is_admin, :boolean, default: false, null: false
    timestamps()
  end
   
   create unique_index(:users, [:email])

