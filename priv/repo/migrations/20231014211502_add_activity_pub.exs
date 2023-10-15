defmodule Chuuni.Repo.Migrations.AddActivityPub do
  use Ecto.Migration

  def up do
    ActivityPub.Migrations.up()
    ActivityPub.Migrations.add_object_boolean()
  end

  def down do
    ActivityPub.Migrations.drop_object_boolean()
    ActivityPub.Migrations.down()
  end
end
