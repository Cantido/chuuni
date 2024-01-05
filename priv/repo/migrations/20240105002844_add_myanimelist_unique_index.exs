defmodule Chuuni.Repo.Migrations.AddMyanimelistUniqueIndex do
  use Ecto.Migration

  def change do
    create unique_index(:anime, ["(external_ids->>'myanimelist')"])
  end
end
