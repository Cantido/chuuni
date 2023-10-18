defmodule Chuuni.Media.FuzzyDate do
  @moduledoc """
  A date that may be either `year`-`month`-`day`, `year`-`month`, or just `year`.
  """

  use Chuuni.Schema

  embedded_schema do
    field :year, :integer
    field :month, :integer
    field :day, :integer
  end

  @doc """
  Returns the ISO 8601 formatted fuzzy date.
  """
  def to_iso8601(date) do
    [date.year, date.month, date.day]
    |> Enum.reject(&is_nil/1)
    |> Enum.map_join("-", &String.pad_leading(to_string(&1), 2, "0"))
  end

  def changeset(model, params) do
    model
    |> cast(params, [:year, :month, :day])
    |> validate_required_year()
    |> validate_required_month()
    |> validate_number(:year, greater_than_or_equal_to: -9999, less_than_or_equal_to: 9999)
    |> validate_number(:month, greater_than_or_equal_to: 1, less_than_or_equal_to: 12)
    |> validate_number(:day, greater_than_or_equal_to: 1, less_than_or_equal_to: 31)
    |> validate_date()
  end

  defp validate_required_year(changeset) do
    if get_field(changeset, :month) do
      changeset
      |> validate_required(:year)
    else
      changeset
    end
  end

  defp validate_required_month(changeset) do
    if get_field(changeset, :day) do
      changeset
      |> validate_required(:month)
    else
      changeset
    end
  end

  defp validate_date(changeset) do
    with {yloc, year} when yloc in [:changes, :data] <- fetch_field(changeset, :year),
         {mloc, month} when mloc in [:changes, :data] <- fetch_field(changeset, :month),
         {dloc, day} when dloc in [:changes, :data] <- fetch_field(changeset, :day)
    do
      if Calendar.ISO.valid_date?(year, month, day) do
        changeset
      else
        add_error(changeset, :day, "is not valid")
      end
    else
      :error -> changeset
    end
  end
end
