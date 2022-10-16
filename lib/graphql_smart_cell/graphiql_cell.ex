defmodule GraphqlSmartCell.GraphiQLCell do
  # Displays the result of a GraphQL query
  @moduledoc false

  use Kino.JS, assets_path: "lib/assets/graphiql_cell"
  use Kino.JS.Live
  use Kino.SmartCell, name: "GraphQL query 2"

  # def new(json) do
  #   Kino.JS.new(__MODULE__, Jason.encode!(json))
  # end

  @impl Kino.JS.Live
  def init(attrs, ctx) do
    "in init" |> IO.puts()

    ctx =
      assign(ctx,
        connections: [],
        connection:
          if conn_attrs = attrs["connection"] do
            %{variable: conn_attrs["variable"], type: conn_attrs["type"]}
          end,
        result_variable: Kino.SmartCell.prefixed_var_name("result", attrs["result_variable"])
      )

    {:ok, ctx}
  end

  @impl Kino.JS.Live
  def handle_connect(ctx) do
    "in handle_connect" |> IO.puts()

    payload = %{
      connections: ctx.assigns.connections,
      connection: ctx.assigns.connection,
      result_variable: ctx.assigns.result_variable
    }

    {:ok, payload, ctx}
  end

  @impl Kino.JS.Live
  def handle_event("update_connection", variable, ctx) do
    "in handle_event update_connection" |> IO.puts()
    connection = Enum.find(ctx.assigns.connections, &(&1.variable == variable))
    ctx = assign(ctx, connection: connection)
    broadcast_event(ctx, "update_connection", connection.variable)
    {:noreply, ctx}
  end

  def handle_event("update_result_variable", variable, ctx) do
    "in handle_event update_result_variable" |> IO.puts()

    ctx =
      if Kino.SmartCell.valid_variable_name?(variable) do
        broadcast_event(ctx, "update_result_variable", variable)
        assign(ctx, result_variable: variable)
      else
        broadcast_event(ctx, "update_result_variable", ctx.assigns.result_variable)
        ctx
      end

    {:noreply, ctx}
  end

  @impl Kino.SmartCell
  def scan_binding(pid, binding, _env) do
    "in scan_binding" |> IO.puts()
    binding |> IO.inspect(label: :binding)

    connections =
      for {key, value} <- binding,
          is_atom(key),
          # type = graphql_result_type(value),
          type = client_type(value),
          do: %{variable: Atom.to_string(key), type: type}

    send(pid, {:connections, connections})
  end

  @impl Kino.JS.Live
  def handle_info({:connections, connections}, ctx) do
    "in handle_info" |> IO.puts()
    connection = search_connection(connections, ctx.assigns.connection)

    broadcast_event(ctx, "connections", %{
      "connections" => connections,
      "connection" => connection
    })

    {:noreply, assign(ctx, connections: connections, connection: connection)}
  end

  defp search_connection([connection | _], nil), do: connection

  defp search_connection([], connection), do: connection

  defp search_connection(connections, %{variable: variable}) do
    case Enum.find(connections, &(&1.variable == variable)) do
      nil -> List.first(connections)
      connection -> connection
    end
  end

  # defp graphql_result_type(value) do
  #   if Map.has_key?(value, "data") or Map.has_key?(value, "errors") do
  #     "graphql_result"
  #   else
  #     nil
  #   end
  # end

  defp client_type(connection) when is_struct(connection, Req.Request) do
    cond do
      Keyword.has_key?(connection.request_steps, :graphql_run) -> "graphql"
      true -> nil
    end
  end

  defp client_type(_connection), do: nil

  @impl Kino.SmartCell
  def to_attrs(ctx) do
    "in to_attrs" |> IO.puts()

    %{
      "connection" =>
        if connection = ctx.assigns.connection do
          %{"variable" => connection.variable, "type" => connection.type}
        end,
      "result_variable" => ctx.assigns.result_variable
    }
  end

  @impl Kino.SmartCell
  def to_source(attrs) do
    "in to_source" |> IO.puts()
    "#{inspect(attrs)}"
  end

  # defp to_quoted(%{"connection" => %{"type" => "graphql_result"}} = attrs) do
  #   to_req_quoted(attrs, fn _n -> "?" end, :graphql_result)
  # end

  # defp to_quoted(_ctx) do
  #   quote do
  #   end
  # end

  # defp to_req_quoted(attrs, _next, req_key) do
  #   #                         👇 these are the GraphQL attributes
  #   query = {attrs["query"], %{}}
  #   opts = []
  #   req_opts = opts |> Enum.at(0, []) |> Keyword.put(req_key, query)

  #   quote do
  #     unquote(quoted_var(attrs["result_variable"])) =
  #       Req.post!(
  #         unquote(quoted_var(attrs["connection"]["variable"])),
  #         unquote(req_opts)
  #       ).body
  #   end
  # end

  # defp quoted_var(nil), do: nil
  # defp quoted_var(string), do: {String.to_atom(string), [], nil}
end
