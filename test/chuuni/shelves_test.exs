defmodule Chuuni.ShelvesTest do
  use Chuuni.DataCase

  alias Chuuni.Shelves

  describe "shelves" do
    alias Chuuni.Shelves.Shelf

    import Chuuni.ShelvesFixtures

    @invalid_attrs %{title: nil}

    test "list_shelves/0 returns all shelves" do
      shelf = shelf_fixture()
      assert Shelves.list_shelves() == [shelf]
    end

    test "get_shelf!/1 returns the shelf with given id" do
      shelf = shelf_fixture()
      assert Shelves.get_shelf!(shelf.id) == shelf
    end

    test "create_shelf/1 with valid data creates a shelf" do
      valid_attrs = %{title: "some title"}

      assert {:ok, %Shelf{} = shelf} = Shelves.create_shelf(valid_attrs)
      assert shelf.title == "some title"
    end

    test "create_shelf/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shelves.create_shelf(@invalid_attrs)
    end

    test "update_shelf/2 with valid data updates the shelf" do
      shelf = shelf_fixture()
      update_attrs = %{title: "some updated title"}

      assert {:ok, %Shelf{} = shelf} = Shelves.update_shelf(shelf, update_attrs)
      assert shelf.title == "some updated title"
    end

    test "update_shelf/2 with invalid data returns error changeset" do
      shelf = shelf_fixture()
      assert {:error, %Ecto.Changeset{}} = Shelves.update_shelf(shelf, @invalid_attrs)
      assert shelf == Shelves.get_shelf!(shelf.id)
    end

    test "delete_shelf/1 deletes the shelf" do
      shelf = shelf_fixture()
      assert {:ok, %Shelf{}} = Shelves.delete_shelf(shelf)
      assert_raise Ecto.NoResultsError, fn -> Shelves.get_shelf!(shelf.id) end
    end

    test "change_shelf/1 returns a shelf changeset" do
      shelf = shelf_fixture()
      assert %Ecto.Changeset{} = Shelves.change_shelf(shelf)
    end
  end
end
