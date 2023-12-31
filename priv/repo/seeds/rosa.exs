{:ok, user} = Chuuni.Accounts.register_user(%{
  display_name: "Rosa",
  name: "rosa",
  email: "rosa@example.com",
  password: "asdfasdfasdf"
})

Chuuni.Accounts.import_mal_profile(user, "cantido")
