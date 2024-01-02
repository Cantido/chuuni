defmodule Chuuni.Repo.Migrations.AddRecommendations do
  use Ecto.Migration

  def change do
    create table(:recommendations) do
      add :user_id, references(:users, on_delete: :delete_all, on_update: :update_all)
      add :anime_id, references(:anime, on_delete: :delete_all, on_update: :update_all)
      add :recommended_id, references(:anime, on_delete: :delete_all, on_update: :update_all)
      add :vote, :string, null: false

      timestamps()
    end

    create unique_index(:recommendations, [:user_id, :anime_id, :recommended_id])
  end
end
