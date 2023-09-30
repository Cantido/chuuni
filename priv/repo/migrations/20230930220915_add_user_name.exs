defmodule Chuuni.Repo.Migrations.AddUserName do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string, null: false
    end

    create unique_index(:users, [:name])
    create constraint(:users, :name_must_be_long, check: "LENGTH(name) >= 3")
  end
end
