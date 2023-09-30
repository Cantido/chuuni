defmodule Chuuni.Reviews.Rating do
  use Ecto.Schema
  import Ecto.Changeset

  alias Chuuni.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "ratings" do
    field :value, :decimal
    field :value_worst, :decimal
    field :value_best, :decimal
    belongs_to :author, User

    timestamps()
  end

  @doc false
  def changeset(rating, attrs) do
    rating
    |> cast(attrs, [:value, :author_id])
    |> assoc_constraint(:author)
    |> validate_required([:value, :value_worst, :value_best])
    |> check_constraint(:value_best, name: :best_greater_than_worst, message: "must be higher than the worst possible value")
    |> check_constraint(:value, name: :value_greater_than_worst, message: "must be higher than the worst possible value")
    |> check_constraint(:value, name: :value_less_than_best, message: "must be less than the best possible value")
  end
end
