defmodule Chuuni.Repo.Migrations.MergeRatingIntoReview do
  use Ecto.Migration

  def change do
    execute("""
    ALTER TABLE reviews ALTER COLUMN body DROP NOT NULL;
    """,
    """
    ALTER TABLE reviews ALTER COLUMN body SET NOT NULL;
    """)

    alter table(:reviews) do
      add :rating, :integer, null: false
    end

    # still in very early development, I don't care about losing data here

    drop table(:ratings)

    create constraint(:reviews, :rating_greater_than_worst, check: "rating >= 1")
    create constraint(:reviews, :rating_less_than_best, check: "rating <= 10")
  end
end
