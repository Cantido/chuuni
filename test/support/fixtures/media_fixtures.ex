defmodule Chuuni.MediaFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chuuni.Media` context.
  """

  @doc """
  Generate a anime.
  """
  def anime_fixture(attrs \\ %{}) do
    {:ok, anime} =
      attrs
      |> Enum.into(%{
        title: %{english: "some title"},
        description: "some description"
      })
      |> Chuuni.Media.create_anime()

    anime
  end
end
