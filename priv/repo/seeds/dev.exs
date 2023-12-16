##
# Dev seed
#
# This script generates a lot of fake website data for testing purposes.

Application.ensure_started(:faker)

# Keep these numbers prime so that when we cycle & zip lists together,
# no combination is repeated until all the sequences are exhausted.
user_count = 1_009
follow_count = 503
anime_count = 101
review_count = 10_007

IO.puts("Creating #{user_count} user profiles...")

user_password_hash = Argon2.hash_pwd_salt("asdfasdfasdf")

user_params =
  Enum.map(1..user_count, fn _ ->
    id = Ecto.UUID.generate()
    %{
      id: id,
      name: Faker.Internet.user_name() <> Integer.to_string(Enum.random(1000..9999)),
      email: "#{id}@example.com",
      hashed_password: user_password_hash,
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }
  end)

{^user_count, users} = Chuuni.Repo.insert_all_chunked(Chuuni.Accounts.User, user_params, returning: true)

IO.puts("Created #{user_count} user profiles.")

IO.puts("Creating user relationships...")

follow_params =
  Stream.zip([
    Stream.cycle(users),
    Stream.cycle(Enum.drop(users, 1))
  ])
  |> Stream.take(follow_count)
  |> Enum.map(fn {user_a, user_b} ->
    %{
      follower_id: user_a.id,
      following_id: user_b.id,
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }
  end)

{^follow_count, _} = Chuuni.Repo.insert_all_chunked(Chuuni.Accounts.Follow, follow_params)

IO.puts("Created user relationships.")

IO.puts("Importing top #{anime_count} trending shows from AniList...")

anime =
  Chuuni.Media.Anilist.trending_anime(anime_count)
  |> Enum.reverse()
  |> Enum.map(fn resp ->
    if existing_anime = Chuuni.Media.get_anime_by_anilist_id(Integer.to_string(resp["id"])) do
      Chuuni.Media.delete_anime(existing_anime)
    end
    {:ok, anime} = Chuuni.Media.Anilist.import_anime_response(resp)
    anime
  end)

IO.puts("Imported #{anime_count} trending shows.")

IO.puts("Writing #{review_count} reviews...")

review_params =
  Stream.zip([
    Stream.cycle(users),
    Stream.cycle(anime)
  ])
  |> Stream.take(review_count)
  |> Enum.map(fn {user, show} ->
    %{
      rating: Enum.random(1..10),
      body: Enum.join(Faker.Lorem.paragraphs(), "\n\n"),
      anime_id: show.id,
      author_id: user.id,
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }
  end)

{^review_count, _} = Chuuni.Repo.insert_all_chunked(Chuuni.Reviews.Review, review_params)

IO.puts("Wrote #{review_count} reviews.")

IO.puts("Dev seed completed!")
