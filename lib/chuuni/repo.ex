defmodule Chuuni.Repo do
  use Ecto.Repo,
    otp_app: :chuuni,
    adapter: Ecto.Adapters.Postgres

  def insert_all_chunked(schema, rows, opts \\ []) do
    fields_per_row =
      Enum.at(rows, 0)
      |> Map.keys()
      |> Enum.count()
      |> then(fn n -> n + 1 end)

    rows_per_batch = div(65_535, fields_per_row)

    IO.inspect(fields_per_row, label: "fields per row")
    IO.inspect(rows_per_batch, label: "rows per batch")
    IO.inspect(rows_per_batch * fields_per_row, label: "fields per batch")

    Enum.chunk_every(rows, rows_per_batch)
    |> Enum.reduce({0, []}, fn batch, {inserted_so_far, returned_so_far} ->
      {inserted_count, returned} = Chuuni.Repo.insert_all(schema, batch, opts)

      {inserted_count + inserted_so_far, reduce_insert_all_output(returned, returned_so_far)}
    end)
  end

  defp reduce_insert_all_output(a, b) when is_list(a) and is_list(b), do: a ++ b
  defp reduce_insert_all_output(_, _), do: nil

end
