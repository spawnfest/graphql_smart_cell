defmodule GraphqlSmartCell.ClientCell do
  @moduledoc false

  # A smart cell used to establish connection to a GraphQL server.

  use Kino.JS, assets_path: "lib/assets/client_cell"
  use Kino.JS.Live
  use Kino.SmartCell, name: "GraphQL connection"

  alias Kino.JS.Live.Context

  @impl true
  def init(attrs, %Context{} = ctx) do
    fields = %{
      "variable" => Kino.SmartCell.prefixed_var_name("conn", attrs["variable"]),
      "url" => attrs["url"] || "http://localhost:4000/api"
    }

    ctx = assign(ctx, fields: fields)

    {:ok, ctx}
  end

  @impl true
  def handle_connect(%Context{} = ctx) do
    payload = %{
      fields: ctx.assigns.fields
    }

    {:ok, payload, ctx}
  end

  @impl true
  def to_attrs(%Context{} = ctx) do
    # raise "NYI: #{inspect(ctx)}"
    ctx.assigns
  end

  @impl true
  def to_source(_attrs) do
    # raise "NYI: #{inspect(ctx)}"
    "function not_yet_implemented() { return 0; }"
  end

  @impl true
  def handle_event("update_field", %{"field" => field, "value" => value}, ctx) do
    updated_fields = to_updates(ctx.assigns.fields, field, value)
    ctx = update(ctx, :fields, &Map.merge(&1, updated_fields))

    _ = broadcast_event(ctx, "update", %{"fields" => updated_fields})

    {:noreply, ctx}
  end

  defp to_updates(fields, "variable", value) do
    if Kino.SmartCell.valid_variable_name?(value) do
      %{"variable" => value}
    else
      %{"variable" => fields["variable"]}
    end
  end

  defp to_updates(fields, "url", value) do
    uri = URI.parse(value)
    # only update url if it is a "complete" url
    # this check might need a more "complete" implementation.
    if uri.scheme == nil || uri.host == nil do
      %{"url" => fields["url"]}
    else
      %{"url" => value}
    end
  end
end
