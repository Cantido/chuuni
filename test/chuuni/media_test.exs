defmodule Chuuni.MediaTest do
  use Chuuni.DataCase

  alias Chuuni.Media

  describe "anime" do
    alias Chuuni.Media.Anime

    import Chuuni.MediaFixtures

    @invalid_attrs %{title: nil}

    test "list_anime/0 returns all anime" do
      anime = anime_fixture()
      assert Media.list_anime() == [anime]
    end

    test "get_anime!/1 returns the anime with given id" do
      anime = anime_fixture()
      assert Media.get_anime!(anime.id) == anime
    end

    test "create_anime/1 with valid data creates a anime" do
      valid_attrs = %{title: %{english: "some title"}, description: "some description"}

      assert {:ok, %Anime{} = anime} = Media.create_anime(valid_attrs)
      assert anime.title.english == "some title"
      assert anime.description == "some description"
    end

    test "create_anime/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Media.create_anime(@invalid_attrs)
    end

    test "update_anime/2 with valid data updates the anime" do
      anime = anime_fixture()
      update_attrs = %{description: "some updated description"}

      assert {:ok, %Anime{} = anime} = Media.update_anime(anime, update_attrs)
      assert anime.description == "some updated description"
    end

    test "update_anime/2 with invalid data returns error changeset" do
      anime = anime_fixture()
      assert {:error, %Ecto.Changeset{}} = Media.update_anime(anime, @invalid_attrs)
      assert anime == Media.get_anime!(anime.id)
    end

    test "delete_anime/1 deletes the anime" do
      anime = anime_fixture()
      assert {:ok, %Anime{}} = Media.delete_anime(anime)
      assert_raise Ecto.NoResultsError, fn -> Media.get_anime!(anime.id) end
    end

    test "change_anime/1 returns a anime changeset" do
      anime = anime_fixture()
      assert %Ecto.Changeset{} = Media.change_anime(anime)
    end
  end
end
