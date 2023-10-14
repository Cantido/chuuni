defmodule Chuuni.Schema do
  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      import Ecto.Changeset

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      @timestamp_opts type: :utc_datetime
    end
  end
end
