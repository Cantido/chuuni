defmodule Chuuni.Repo.Migrations.ReviewForeignKeys do
  use Ecto.Migration

  def change do
    alter table(:reviews) do
      modify :anime_id, references(:anime, on_delete: :delete_all, on_update: :update_all, type: :binary_id),
        from: references(:anime, on_delete: :nothing, type: :binary_id)
    end
  end
end
