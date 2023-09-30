defmodule Chuuni.Repo.Migrations.AddRatedItem do
  use Ecto.Migration

  def change do
    alter table(:ratings) do
      add :item_rated, :string, null: false
    end

    create unique_index(:ratings, [:author_id, :item_rated])
  end
end
