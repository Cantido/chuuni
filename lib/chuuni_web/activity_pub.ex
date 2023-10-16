defmodule ChuuniWeb.ActivityPub.Adapter do
  use ChuuniWeb, :verified_routes

  alias ActivityPub.Actor
  alias Chuuni.Accounts
  alias Chuuni.Accounts.User
  alias Chuuni.Repo

  import Ecto.Query

  require Logger

  @behaviour ActivityPub.Federator.Adapter

  def base_url do
    ChuuniWeb.Endpoint.url()
  end

  def get_redirect_url(username) do
    user = Accounts.get_user_by_name(username)

    if user do
      ~p"/@#{username}"
    end
  end

  def get_actor_by_ap_id(ap_id) do
    user_path = ChuuniWeb.Endpoint.url() <> "/pub/actors/"
    if String.starts_with?(ap_id, user_path) do
      {^user_path, username} = String.split_at(ap_id, String.length(user_path))

      get_actor_by_username(username)
    else
      {:error, :remote_actor}
    end
  end

  def get_actor_by_id(id) do
    if user = Accounts.get_user!(id) do
      user_to_actor(user)
    else
      {:error, :not_found}
    end
  end

  def get_actor_by_username(username) do
    if user = Accounts.get_user_by_name(username) do
      user_to_actor(user)
    else
      {:error, :not_found}
    end
  end

  def user_to_actor(%User{} = user) do
    ap_id = ChuuniWeb.Endpoint.url() <> ~p"/pub/actors/#{user.name}"

    {:ok, %Actor{
      ap_id: ap_id,
      id: user.id,
      local: true,
      username: user.name,
      deactivated: false,
      keys: user.keys,
      updated_at: user.updated_at,
      data: %{
        "type" => "Person",
        "id" => ap_id,
        "inbox" => ChuuniWeb.Endpoint.url() <> ~p"/pub/actors/#{user.name}/inbox",
        "outbox" => ChuuniWeb.Endpoint.url() <> ~p"/pub/actors/#{user.name}/outbox",
        "followers" => ChuuniWeb.Endpoint.url() <> ~p"/pub/actors/#{user.name}/followers",
        "following" => ChuuniWeb.Endpoint.url() <> ~p"/pub/actors/#{user.name}/following"
      }
    }}
  end

  def get_follower_local_ids(%Actor{} = actor) do
    Repo.all(
      from u in User,
        where: [id: ^actor.id],
        join: follower in assoc(u, :followers),
        select: follower.id
    )
  end

  def get_following_local_ids(%Actor{} = actor) do
    Repo.all(
      from u in User,
        where: [id: ^actor.id],
        join: following in assoc(u, :following),
        select: following.id
    )
  end

  def get_locale, do: "en"

  def update_local_actor(%Actor{} = actor, %{keys: keys} = params) when is_binary(keys) do
    user = Accounts.get_user!(actor.id)

    case Accounts.update_user_keys(user, params) do
      {:ok, user} -> {:ok, %Actor{actor | keys: user.keys}}
      {:error, error} ->
        Logger.error("error updating user keys: #{inspect error}")
        {:error, error}
    end
  end
end
