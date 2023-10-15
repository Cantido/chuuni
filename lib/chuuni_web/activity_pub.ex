defmodule ChuuniWeb.ActivityPub.Adapter do
  use ChuuniWeb, :verified_routes

  alias ActivityPub.Actor
  alias Chuuni.Accounts
  alias Chuuni.Repo

  require Logger

  @behaviour ActivityPub.Federator.Adapter

  def get_redirect_url(username) do
    user = Accounts.get_user_by_name(username)

    if user do
      ~p"/@#{username}"
    end
  end

  def get_actor_by_username(username) do
    if user = Accounts.get_user_by_name(username) do
      {:ok, %Actor{
        id: user.id,
        local: true,
        keys: user.keys,
        ap_id: "#{ChuuniWeb.Endpoint.url()}/@#{user.name}",
        username: user.name,
        data: %{}
      }}
    else
      {:error, :not_found}
    end
  end

  def update_local_actor(%Actor{} = actor, %{keys: keys} = params) when is_binary(keys) do
    user = Accounts.get_user!(actor.id)

    case Accounts.update_user_keys(user, params) do
      {:ok, user} -> {:ok, %Actor{actor | keys: user.keys}}
      {:error, error} ->
        Logger.error("error updating user keys: #{inspect error}")
        {:error, error}
    end
  end

  def get_locale, do: "en"
end
