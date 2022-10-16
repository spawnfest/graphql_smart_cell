defmodule GraphqlSmartCell.ClientCell do
  @moduledoc false

  use Kino.JS, assets_path: "lib/assets/client_cell"
  use Kino.JS.Live
  use Kino.SmartCell, name: "GraphQL client"

  alias Kino.JS.Live.Context

  @impl Kino.JS.Live
  def init(attrs, %Context{} = ctx) do
    fields = %{
      "url" => "/graphql",
      "subscriptions" => "/socket/websocket",
      "type" => "graphql",
      "scheme" => "https",
      "variable" => Kino.SmartCell.prefixed_var_name("client", attrs["variable"])
    }

    ctx = Context.assign(ctx, fields: fields)

    {:ok, ctx}
  end

  @impl Kino.JS.Live
  def handle_connect(%Context{} = ctx) do
    initial_attrs = %{
      fields: ctx.assigns.fields
      # missing_dep: ctx.assigns.missing_dep,
      # help_box: ctx.assigns.help_box,
    }

    {:ok, initial_attrs, ctx}
  end

  @default_keys ["type", "variable"]

  @impl Kino.SmartCell
  def to_attrs(%{assigns: %{fields: fields}}) do
    connection_keys = ~w|scheme hostname url subscriptions|
    Map.take(fields, @default_keys ++ connection_keys)
  end

  @impl Kino.SmartCell
  def to_source(attrs) do
    url = attrs |> origin() |> URI.new!()
    url |> to_quoted(attrs) |> Kino.SmartCell.quoted_to_string()
  end

  defp to_quoted(%URI{} = uri, %{"type" => "graphql"} = attrs) do
    req_opts =
      attrs
      |> Map.take(["url"])
      |> Enum.into([], fn {key, value} -> {String.to_atom(key), value} end)
      |> Keyword.put(:base_url, URI.to_string(uri))

    quote do
      unquote(quoted_var(attrs["variable"])) =
        Req.new(unquote(req_opts))
        |> AbsintheClient.attach()
    end
  end

  defp to_quoted(_uri, _ctx) do
    quote do
    end
  end

  defp quoted_var(nil), do: nil
  defp quoted_var(string), do: {String.to_atom(string), [], nil}

  @impl Kino.JS.Live
  def handle_event("update_field", %{"field" => field, "value" => value}, ctx) do
    # event comes into this function from the frontend.
    updated_fields = to_updates(ctx.assigns.fields, field, value)

    # run the code to update the pertinent fields.
    ctx = Context.update(ctx, :fields, &Map.merge(&1, updated_fields))

    # push the changes to the fields back to the frontend.
    _ = Context.broadcast_event(ctx, "update", %{"fields" => updated_fields})

    {:noreply, ctx}
  end

  defp to_updates(fields, "variable", value) do
    # calls into the deep magic :elixir_config
    if is_binary(value) && Kino.SmartCell.valid_variable_name?(value) do
      %{"variable" => value}
    else
      %{"variable" => fields["variable"]}
    end
  end

  defp to_updates(fields, "hostname", value) do
    if is_binary(value) && String.trim(value) != "" do
      %{"hostname" => value}
    else
      %{"hostname" => fields["hostname"]}
    end
  end

  defp to_updates(_fields, field, value), do: %{field => value}

  defp origin(%{"hostname" => hostname} = fields) when is_binary(hostname) do
    scheme = fields["scheme"] |> String.trim() |> scheme()
    # todo: support custom ports
    "#{scheme}://#{hostname}"
  end

  defp origin(_fields), do: ""

  defp scheme(""), do: "https"
  defp scheme(scheme), do: scheme
end
