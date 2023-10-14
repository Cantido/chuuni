defmodule Chuuni.Reviews.ReviewSummary do
  use Chuuni.Schema

  alias Chuuni.Media.Anime

  embedded_schema do
    belongs_to :anime, Anime
    field :rating, :decimal
    field :count, :integer
  end
end
