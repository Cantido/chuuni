defmodule Chuuni.Reviews.Review do
  use Ecto.Schema
  import Ecto.Changeset

  alias Chuuni.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "reviews" do
    field :body, :string
    field :item_reviewed, :string
    belongs_to :author, User

    timestamps()
  end

  @doc false
  def changeset(review, attrs) do
    review
    |> cast(attrs, [:item_reviewed, :body, :author_id])
    |> assoc_constraint(:author)
    |> validate_required([:item_reviewed, :body])
  end
end
