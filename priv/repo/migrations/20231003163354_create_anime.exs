defmodule Chuuni.Repo.Migrations.CreateAnime do
  use Ecto.Migration

  def change do
    create table(:anime, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :map
      add :external_ids, :map
      add :description, :string, size: 32768

      timestamps()
    end

    create unique_index(:anime, ["(external_ids->>'anilist')"])

    alter table(:reviews) do
      remove :item_reviewed, :string, null: false
      add :anime_id, references(:anime, on_delete: :nothing, type: :binary_id), null: false
    end

    create unique_index(:reviews, [:author_id, :anime_id])
  end
end
