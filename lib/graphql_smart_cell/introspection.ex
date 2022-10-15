defmodule GraphqlSmartCell.Introspection do
  alias Req.Request

  @query_file :graphql_smart_cell
              |> :code.priv_dir()
              |> to_string()
              |> Path.join("graphql/introspection.graphql")

  @external_resource @query_file

  @query File.read!(@query_file)

  def get(%Request{} = client, opts \\ []) do
    opts = Keyword.put(opts, :graphql, {@query, %{}})
    Req.post!(client, opts).body
  end
end
