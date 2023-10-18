defmodule Chuuni.Repo.Migrations.AddDatesToAnime do
  use Ecto.Migration

  def change do
    alter table(:anime) do
      # We have to deal with "fuzzy" dates, i.e. just year or just year & month
      add :start_date, :map
      add :stop_date, :map
    end
  end
end
