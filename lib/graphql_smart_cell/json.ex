defmodule GraphqlSmartCell.JSON do
  use Kino.JS, assets_path: "lib/assets/json"

  def new(json) do
    Kino.JS.new(__MODULE__, Jason.encode!(json))
  end
end
