defmodule Chuuni.Accounts.MyanimelistImportWorker do
 use Oban.Worker, max_attempts: 3

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_id" => user_id, "mal_username" => mal_username}}) do
    user = Chuuni.Accounts.get_user!(user_id)

    Chuuni.Accounts.import_mal_profile(user, mal_username)
  end
end
