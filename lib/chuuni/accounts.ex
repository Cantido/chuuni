defmodule Chuuni.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Chuuni.Repo
  alias Chuuni.Media.Anime
  alias Chuuni.Media.Anilist

  alias Chuuni.Accounts.{Follow, User, UserToken, UserNotifier, UserQueries}

  require Logger

  def get_followers(%User{} = user) do
    Repo.all(
      from u in User,
        where: [id: ^user.id],
        join: follower in assoc(u, :followers),
        select: follower
    )
  end

  def get_follower_count(%User{} = user) do
    UserQueries.user_by_id(user.id)
    |> UserQueries.follower_count()
    |> Repo.one()
  end

  def get_following_count(%User{} = user) do
    UserQueries.user_by_id(user.id)
    |> UserQueries.following_count()
    |> Repo.one()
  end

  def change_follow(%User{} = follower, %User{} = following) do
    Follow.create_changeset(follower, following)
  end

  def follow(%User{} = follower, %User{} = following) do
    case Repo.insert(change_follow(follower, following)) do
      {:ok, follow} ->
        {:ok, actor} = ChuuniWeb.ActivityPub.Adapter.user_to_actor(follower)
        {:ok, object} = ChuuniWeb.ActivityPub.Adapter.user_to_actor(following)

        {:ok, follow_object} = ActivityPub.follow(%{actor: actor, object: object})
        {:ok, _accept_object} = ActivityPub.accept(follow_object)
        {:ok, follow}
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def unfollow(%User{} = follower, %User{} = following) do
    case Repo.delete_all(from f in Follow, where: [follower_id: ^follower.id, following_id: ^following.id]) do
      {count, _} when is_integer(count) ->
        {:ok, actor} = ChuuniWeb.ActivityPub.Adapter.user_to_actor(follower)
        {:ok, object} = ChuuniWeb.ActivityPub.Adapter.user_to_actor(following)

        ActivityPub.unfollow(%{actor: actor, object: object})
        :ok
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def following?(%User{} = follower, %User{} = following) do
    Repo.exists?(from f in Follow, where: [follower_id: ^follower.id, following_id: ^following.id])
  end

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  def get_user_by_name(name) when is_binary(name) do
    Repo.get_by(User, name: name)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    User.new_changeset()
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: false)
  end

  def change_user_keys(%User{} = user, attrs \\ %{}) do
    User.key_changeset(user, attrs)
  end

  def update_user_keys(%User{} = user, attrs) do
    user
    |> change_user_keys(attrs)
    |> Repo.update()
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, [context]))
  end

  def change_user_display_name(%User{} = user, attrs \\ %{}) do
    User.display_name_changeset(user, attrs)
  end

  def update_user_display_name(%User{} = user, attrs \\ %{}) do
    User.display_name_changeset(user, attrs)
    |> Repo.update()
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &url(~p"/users/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &url(~p"/users/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  def import_mal_profile(%User{} = user, username) when is_binary(username) do
    unless username =~ ~r/^[a-zA-Z0-9]{2,16}$/ do
      raise "Not a valid MAL username: #{inspect username}."
    end

    user_shelves = Chuuni.Shelves.list_shelves_for_user(user)
    client_id =
      Application.fetch_env!(:chuuni, :myanimelist)
      |> Keyword.fetch!(:client_id)

    {:ok, resp} = HTTPoison.get("https://api.myanimelist.net/v2/users/#{username}/animelist?fields=list_status{status,score,comments}&limit=1000", [{"X-MAL-CLIENT-ID", client_id}])

    Jason.decode!(resp.body)
    |> Map.fetch!("data")
    |> tap(fn data ->
      Logger.debug("Importing #{Enum.count(data)} list entries from MyAnimeList...")
    end)
    |> Enum.map(fn list_node ->
      anime_mal_id = list_node["node"]["id"]

      mal_list_name = list_node["list_status"]["status"]

      target_list_name =
        case mal_list_name do
          "watching" -> "Watching"
          "completed" -> "Completed"
          "on_hold" -> "On Hold"
          "dropped" -> "Dropped"
          "plan_to_watch" -> "Plan to Watch"
          nil -> nil
        end

      target_shelf = Enum.find(user_shelves, &(&1.title == target_list_name))

      rating = list_node["list_status"]["score"]
      review_comment = list_node["list_status"]["comments"]

      {anime_mal_id, target_shelf, rating, review_comment}
    end)
    |> then(fn nodes ->
      mal_ids = Enum.map(nodes, &elem(&1, 0))

      local_anime = Repo.all(from a in Anime, where: a.external_ids["myanimelist"] in ^mal_ids, select: {a.external_ids["myanimelist"], a}) |> Map.new()
      have_ids = Map.keys(local_anime)

      anime_to_import =
        Enum.reject(mal_ids, fn mal_id ->
          Enum.member?(have_ids, mal_id)
        end)

      rest_anime =
        Enum.chunk_every(anime_to_import, 50)
        |> Enum.with_index()
        |> Enum.flat_map(fn {chunk, page_number} ->
          {:ok, rest_anime} = Anilist.import_mal_anime(chunk, page_number + 1, 50)
          rest_anime
        end)

      all_anime = Map.merge(local_anime, Map.new(rest_anime, fn anime -> {String.to_integer(anime.external_ids.myanimelist), anime} end))

      Enum.map(nodes, fn {mal_id, shelf, rating, comment} ->
        if anime = Map.get(all_anime, mal_id) do
          {anime, shelf, rating, comment}
        else
          nil
        end
      end)
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.each(fn {anime, target_shelf, rating, review_comment} ->
      {:ok, _shelf_item} = Chuuni.Shelves.create_shelf_item(%{anime_id: anime.id, shelf_id: target_shelf.id}, user)

      if rating in 1..10 do
        {:ok, _review} = Chuuni.Reviews.create_review(%{rating: rating, body: review_comment, author_id: user.id, anime_id: anime.id})
      end
    end)
  end
end
