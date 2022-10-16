defmodule GraphqlSmartCell.ResultCell do
  # Displays the result of a GraphQL query
  @moduledoc false

  use Kino.JS, assets_path: "lib/assets/result_cell"
  use Kino.JS.Live
  use Kino.SmartCell, name: "GraphQL result"

  alias Kino.JS.Live.Context

  @impl Kino.JS.Live
  def init(attrs, ctx) do
    ctx =
      assign(ctx,
        connections: [],
        connection:
          if conn_attrs = attrs["connection"] do
            %{variable: conn_attrs["variable"], type: conn_attrs["type"]}
          end,
        result_variable: Kino.SmartCell.prefixed_var_name("data", attrs["result_variable"]),
        variable: Kino.SmartCell.prefixed_var_name("req_response", attrs["variable"])
      )

    {:ok, ctx}
  end

  @impl Kino.JS.Live
  def handle_connect(ctx) do
    payload = %{
      connections: ctx.assigns.connections,
      connection: ctx.assigns.connection,
      result_variable: ctx.assigns.result_variable,
      variable: ctx.assigns.variable
    }

    {:ok, payload, ctx}
  end

  @impl Kino.JS.Live
  def handle_event("update_connection", variable, ctx) do
    connection = Enum.find(ctx.assigns.connections, &(&1.variable == variable))
    ctx = assign(ctx, connection: connection)
    broadcast_event(ctx, "update_connection", connection.variable)
    {:noreply, ctx}
  end

  # Is this right? Or even needed?
  def handle_event("update_connections", connections, ctx) do
    ctx = assign(ctx, connections: connections)
    broadcast_event(ctx, "update_connections", connections)
    {:noreply, ctx}
  end

  def handle_event("update_result_variable", variable, ctx) do
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

  def handle_event("update_field", %{"field" => field, "value" => value}, ctx) do
    # event comes into this function from the frontend.
    updated_fields = to_updates(ctx.assigns.fields, field, value)

    # run the code to update the pertinent fields.
    ctx = Context.update(ctx, :fields, &Map.merge(&1, updated_fields))

    # push the changes to the fields back to the frontend.
    _ = Context.broadcast_event(ctx, "update", %{"fields" => updated_fields})

    {:noreply, ctx}
  end

  @impl Kino.SmartCell
  def scan_binding(pid, binding, _env) do
    connections =
      for {key, value} <- binding,
          is_atom(key),
          type = req_response_type(value),
          do: %{variable: Atom.to_string(key), type: type}

    send(pid, {:connections, connections})
  end

  @impl Kino.JS.Live
  def handle_info({:connections, connections}, ctx) do
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

  defp req_response_type(value) do
    if is_struct(value, Req.Response) do
      "req_response"
    else
      nil
    end
  end

  @impl Kino.SmartCell
  def to_attrs(ctx) do
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
    attrs |> to_quoted() |> Kino.SmartCell.quoted_to_string()
  end

  # "data = %AbsintheClientResult{req_response: req_response}"
  defp to_quoted(attrs) do
    quote do
      unquote(quoted_var(attrs["result_variable"])) = %AbsintheClientResult{
        req_response: unquote(quoted_var(attrs["connection"]["variable"]))
      }
    end
  end

  defp quoted_var(nil), do: nil
  defp quoted_var(string), do: {String.to_atom(string), [], nil}

  defp to_updates(fields, "variable", value) do
    # update variable name only if it is valid.
    if is_variable_valid?(value) do
      %{"variable" => value}
    else
      %{"variable" => fields["variable"]}
    end
  end

  defp is_variable_valid?(value) do
    # calls into the deep magic :elixir_config
    is_binary(value) && Kino.SmartCell.valid_variable_name?(value)
  end
end
