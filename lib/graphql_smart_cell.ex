defmodule GraphqlSmartCell do
  @moduledoc """
  Documentation for `GraphqlSmartCell`.
  """

  def build_connection(url) do
    # FAKE THE FUNK.
    me = self()

    spawn(fn ->
      receive do
        x -> send(me, {:connection, url, x})
      end
    end)
  end
end
