defmodule Chuuni.Repo.Migrations.AddFollowers do
  use Ecto.Migration

  def change do
    create table(:follows, primary_key: false) do
      add :follower_id, references(:users, on_delete: :nothing), primary_key: true
      add :following_id, references(:users, on_delete: :nothing), primary_key: true

      timestamps()
    end

    create constraint(:follows, :cannot_follow_yourself, check: "following_id != follower_id")
  end
end
