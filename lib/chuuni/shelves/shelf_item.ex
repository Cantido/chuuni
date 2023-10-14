defmodule Chuuni.Shelves.ShelfItem do
  use Chuuni.Schema
  alias Chuuni.Shelves.Shelf
  alias Chuuni.Media.Anime
  alias Chuuni.Accounts.User
  alias Chuuni.Reviews.Review

  @primary_key false
  schema "shelf_items" do
    belongs_to :shelf, Shelf
    belongs_to :author, User
    belongs_to :anime, Anime

    field :started_at, :date
    field :finished_at, :date

    timestamps()
  end

  @doc false
  def changeset(shelf_item, attrs) do
    shelf_item
    |> cast(attrs, [:shelf_id, :anime_id, :author_id, :started_at, :finished_at])
    |> validate_required([:shelf_id, :anime_id, :author_id])
    |> assoc_constraint(:shelf)
    |> assoc_constraint(:author)
    |> assoc_constraint(:anime)
    |> validate_date_range(:started_at, :finished_at)
  end

  defp validate_date_range(changeset, start_field, finish_field) do
    start_date = get_field(changeset, start_field)
    finish_date = get_field(changeset, finish_field)

    if start_date && finish_date do
      if Date.compare(start_date, finish_date) in [:lt, :eq] do
        changeset
      else
        add_error(
          changeset,
          :end_date,
          "must be after %{start_field}, which is %{start_date}",
          start_field: start_field,
          start_date: start_date
        )
      end
    else
      changeset
    end
  end
end
