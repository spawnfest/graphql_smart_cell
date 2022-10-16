defmodule GraphqlSmartCell.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Kino.SmartCell.register(GraphqlSmartCell.ClientCell)
    Kino.SmartCell.register(GraphqlSmartCell.QueryCell)
    Kino.SmartCell.register(GraphqlSmartCell.ResultCell)
    Kino.SmartCell.register(GraphqlSmartCell.GraphiQLCell)

    children = []
    opts = [strategy: :one_for_one, name: GraphqlSmartCell.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
