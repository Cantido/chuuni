defmodule Chuuni.Reviews.Review do
  use Ecto.Schema
  import Ecto.Changeset

  alias Chuuni.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts type: :utc_datetime
  schema "reviews" do
    field :rating, :integer
    field :body, :string
    field :item_reviewed, :string
    belongs_to :author, User

    timestamps()
  end

  @doc false
  def changeset(review, attrs) do
    review
    |> cast(attrs, [:item_reviewed, :rating, :body, :author_id])
    |> assoc_constraint(:author)
    |> validate_required([:item_reviewed, :rating])
    |> validate_inclusion(:rating, 1..10)
  end
end
