defmodule AbsintheClientResult do
  defstruct [:req_response]
end

defimpl Kino.Render, for: AbsintheClientResult do
  def to_livebook(result) do
    GraphqlSmartCell.JSON
    |> Kino.JS.new(result.req_response.body)
    |> Kino.Render.to_livebook()
  end
end
