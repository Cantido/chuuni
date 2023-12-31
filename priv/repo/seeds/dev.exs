##
# Dev seed
#
# This script generates a lot of fake website data for testing purposes.

import Ecto.Query

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
      display_name: Faker.Person.name(),
      name: Faker.Internet.user_name() <> Integer.to_string(Enum.random(1000..9999)),
      email: "#{id}@example.com",
      hashed_password: user_password_hash,
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }
  end)

{^user_count, users} = Chuuni.Repo.insert_all_chunked(Chuuni.Accounts.User, user_params, returning: true)

IO.puts("Created #{user_count} user profiles.")

shelves =
  Enum.flat_map(users, fn user ->
    [
      "Watching",
      "Completed",
      "On Hold",
      "Dropped",
      "Plan to Watch"
    ]
    |> Enum.map(fn title ->
      %{
        title: title,
        author_id: user.id,
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      }
    end)
  end)

shelf_count = user_count * 5
{^shelf_count, _} = Chuuni.Repo.insert_all_chunked(Chuuni.Shelves.Shelf, shelves)

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
  |> then(fn resp ->
    mal_ids =
      Enum.map(resp, fn resp -> resp["id"] end)

    existing_ids =
      Chuuni.Repo.all(from a in Chuuni.Media.Anime, where: a.external_ids["myanimelist"] in ^mal_ids, select: a.external_ids["myanimelist"])
      |> Enum.map(&String.to_integer/1)

    ids_to_import = MapSet.difference(MapSet.new(mal_ids), MapSet.new(existing_ids))

    Enum.filter(resp, fn resp_item ->
      resp_item["id"] in ids_to_import
    end)
    |> Enum.map(fn resp_item ->
      {:ok, anime} = Chuuni.Media.Anilist.import_anime_response(resp_item)
      anime
    end)
  end)

IO.puts("Imported #{anime_count} trending shows.")

IO.puts("Writing #{review_count} reviews...")

review_params =
  Stream.cycle(users)
  |> Stream.unfold(fn users_stream ->
    chunk_size = Enum.random(0..500)
    {Stream.take(users_stream, chunk_size), Stream.drop(users_stream, chunk_size)}
  end)
  |> Stream.zip(Stream.cycle(anime))
  |> Stream.flat_map(fn {users, show} ->
    mean_rating = :rand.normal(7.5, 3)

    Enum.map(users, fn user ->
      rating =
        :rand.normal(mean_rating, 2)
        |> max(1.0)
        |> min(10.0)
        |> Float.round()
        |> trunc()

      %{
        rating: rating,
        body: Enum.join(Faker.Lorem.paragraphs(), "\n\n"),
        anime_id: show.id,
        author_id: user.id,
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      }
    end)
  end)
  |> Enum.take(review_count)


{^review_count, _} = Chuuni.Repo.insert_all_chunked(Chuuni.Reviews.Review, review_params)

IO.puts("Wrote #{review_count} reviews.")

IO.puts("Dev seed completed!")
