defmodule Chuuni.Repo.Migrations.AddActors do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :keys, :binary, length: 4096
    end
  end
end
