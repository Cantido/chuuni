defmodule Chuuni.Repo.Migrations.CreateRatings do
  use Ecto.Migration

  def change do
    create table(:ratings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :value, :decimal, null: false
      add :value_worst, :decimal, null: false
      add :value_best, :decimal, null: false
      add :author_id, references(:users, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:ratings, [:author_id])

    create constraint(:ratings, :best_greater_than_worst, check: "value_best >= value_worst")
    create constraint(:ratings, :value_greater_than_worst, check: "value >= value_worst")
    create constraint(:ratings, :value_less_than_best, check: "value <= value_best")
  end
end
