defmodule GraphqlSmartCell.QueryCell do
  @moduledoc false

  use Kino.JS, assets_path: "lib/assets/query_cell"
  use Kino.JS.Live
  use Kino.SmartCell, name: "GraphQL query"

  @impl true
  def init(attrs, ctx) do
    ctx =
      assign(ctx,
        clients: [],
        client:
          if conn_attrs = attrs["client"] do
            %{variable: conn_attrs["variable"], type: conn_attrs["type"]}
          end,
        result_variable: Kino.SmartCell.prefixed_var_name("result", attrs["result_variable"]),
        timeout: attrs["timeout"],
        cache_query: attrs["cache_query"] || true,
        query: ""
      )

    # {:ok, ctx, editor: [attribute: "query", language: "graphql"]}
    {:ok, ctx}
  end

  @impl true
  def handle_connect(ctx) do
    payload = %{
      clients: ctx.assigns.clients,
      client: ctx.assigns.client,
      result_variable: ctx.assigns.result_variable,
      timeout: ctx.assigns.timeout,
      cache_query: ctx.assigns.cache_query
    }

    {:ok, payload, ctx}
  end

  @impl true
  def handle_event("update_client", variable, ctx) do
    client = Enum.find(ctx.assigns.clients, &(&1.variable == variable))
    ctx = assign(ctx, client: client)
    broadcast_event(ctx, "update_client", client.variable)
    {:noreply, ctx}
  end

  def handle_event("update_query", query, ctx) do
    broadcast_event(ctx, "update_query", query)
    ctx = assign(ctx, query: query)

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

  def handle_event("update_timeout", timeout, ctx) do
    timeout =
      case Integer.parse(timeout) do
        {n, ""} -> n
        _ -> nil
      end

    ctx = assign(ctx, timeout: timeout)
    broadcast_event(ctx, "update_timeout", timeout)
    {:noreply, ctx}
  end

  def handle_event("update_cache_query", cache_query?, ctx) do
    ctx = assign(ctx, cache_query: cache_query?)
    broadcast_event(ctx, "update_cache_query", cache_query?)
    {:noreply, ctx}
  end

  @impl true
  def scan_binding(pid, binding, _env) do
    clients =
      for {key, value} <- binding,
          is_atom(key),
          type = client_type(value),
          do: %{variable: Atom.to_string(key), type: type}

    send(pid, {:clients, clients})
  end

  @impl true
  def handle_info({:clients, clients}, ctx) do
    client = search_client(clients, ctx.assigns.client)

    broadcast_event(ctx, "clients", %{
      "clients" => clients,
      "client" => client
    })

    {:noreply, assign(ctx, clients: clients, client: client)}
  end

  defp search_client([client | _], nil), do: client

  defp search_client([], client), do: client

  defp search_client(clients, %{variable: variable}) do
    case Enum.find(clients, &(&1.variable == variable)) do
      nil -> List.first(clients)
      client -> client
    end
  end

  defp client_type(client) when is_struct(client, Req.Request) do
    cond do
      Keyword.has_key?(client.request_steps, :graphql_run) -> "graphql"
      true -> nil
    end
  end

  defp client_type(_client), do: nil

  @impl true
  def to_attrs(ctx) do
    %{
      "client" =>
        if client = ctx.assigns.client do
          %{"variable" => client.variable, "type" => client.type}
        end,
      "result_variable" => ctx.assigns.result_variable,
      "timeout" => ctx.assigns.timeout,
      "cache_query" => ctx.assigns.cache_query
    }
  end

  @impl true
  def to_source(attrs) do
    attrs |> to_quoted() |> Kino.SmartCell.quoted_to_string()
  end

  defp to_quoted(%{"client" => %{"type" => "graphql"}} = attrs) do
    to_req_quoted(attrs, fn _n -> "?" end, :graphql)
  end

  defp to_quoted(_ctx) do
    quote do
    end
  end

  defp to_req_quoted(attrs, _next, req_key) do
    #                         👇 these are the GraphQL attributes
    query = {attrs["query"], %{}}
    opts = []
    req_opts = opts |> Enum.at(0, []) |> Keyword.put(req_key, query)

    quote do
      unquote(quoted_var(attrs["result_variable"])) = %AbsintheClientResult{
        req_response:
          Req.post!(
            unquote(quoted_var(attrs["client"]["variable"])),
            unquote(req_opts)
          )
      }
    end
  end

  defp quoted_var(nil), do: nil
  defp quoted_var(string), do: {String.to_atom(string), [], nil}
end
