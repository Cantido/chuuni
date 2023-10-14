defmodule Chuuni.Repo.Migrations.AddActivityPub do
  use Ecto.Migration

  def up, do: ActivityPub.Migrations.up()
end
