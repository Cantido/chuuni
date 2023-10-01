defmodule Chuuni.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :item_reviewed, :string, null: false
      add :body, :string, size: 32768, null: false
      add :author_id, references(:users, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:reviews, [:author_id])
  end
end
