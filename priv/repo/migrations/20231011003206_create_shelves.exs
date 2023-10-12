defmodule Chuuni.Repo.Migrations.CreateShelves do
  use Ecto.Migration

  def change do
    create table(:shelves, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :author_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end


    create index(:shelves, [:author_id])
    create unique_index(:shelves, [:author_id, :title])
    create unique_index(:shelves, [:id, :author_id])

    create table(:shelf_items, primary_key: false) do
      add :shelf_id, references(:shelves, on_delete: :delete_all, type: :binary_id, with: [author_id: :author_id]), primary_key: true
      add :author_id, :binary_id

      add :anime_id, references(:anime, on_delete: :delete_all, type: :binary_id), primary_key: true

      add :started_at, :date
      add :finished_at, :date

      timestamps()
    end

    create constraint(:shelf_items, :started_before_finished, check: "(started_at IS NULL) OR (finished_at IS NULL) OR (started_at <= finished_at)")

    create unique_index(:shelf_items, [:author_id, :anime_id])
  end
end
