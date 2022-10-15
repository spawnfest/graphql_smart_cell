defmodule GraphqlSmartCell.ClientCell do
  @moduledoc false

  # A smart cell used to establish connection to a GraphQL server.

  # use Kino.JS, assets_path: "lib/assets/client_cell"
  use Kino.JS.Live
  use Kino.SmartCell, name: "GraphQL connection"

  @impl true
  def init(attrs, ctx) do
    {:ok, ctx}
  end
end
