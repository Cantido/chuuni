defmodule Chuuni.Accounts.Follow do
  use Chuuni.Schema

  alias Chuuni.Accounts.User

  @primary_key false
  schema "follows" do
    belongs_to :follower, User
    belongs_to :following, User

    timestamps()
  end

  def create_changeset(%User{} = follower, %User{} = following) do
    changeset(%__MODULE__{}, %{follower_id: follower.id, following_id: following.id})
  end


  def changeset(model, params) do
    model
    |> cast(params, [:follower_id, :following_id])
    |> validate_required([:follower_id, :following_id])
    |> assoc_constraint(:follower)
    |> assoc_constraint(:following)
  end
end
