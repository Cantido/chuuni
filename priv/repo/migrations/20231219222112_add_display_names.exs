defmodule Chuuni.Repo.Migrations.AddDisplayNames do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :display_name, :string, null: false
    end
  end
end
