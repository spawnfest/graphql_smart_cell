defmodule GraphqlSmartCell.Introspection do
  alias Req.Request

  @query_file :graphql_smart_cell
              |> :code.priv_dir()
              |> to_string()
              |> Path.join("graphql/introspection.graphql")

  @external_resource @query_file

  @query File.read!(@query_file)

  def get(%Request{} = client, opts \\ []) do
    opts =
      opts
      |> Keyword.put(:graphql, {@query, %{}})
      # TODO: fix this. "JUST DOOO IT -Crumm
      |> Keyword.put(:params, %{operationName: "IntrospectionQuery"})

    Req.post!(client, opts).body
  end
end
