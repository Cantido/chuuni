defmodule Chuuni.ShelvesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chuuni.Shelves` context.
  """

  @doc """
  Generate a shelf.
  """
  def shelf_fixture(attrs \\ %{}) do
    {:ok, shelf} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> Chuuni.Shelves.create_shelf()

    shelf
  end
end
