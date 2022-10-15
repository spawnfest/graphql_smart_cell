defmodule GraphqlSmartCell.ClientCell do
  @moduledoc false

  use Kino.JS, assets_path: "lib/assets/client_cell"
  use Kino.JS.Live
  use Kino.SmartCell, name: "GraphQL connection"

  alias Kino.JS.Live.Context

  @impl Kino.JS.Live
  def init(attrs, %Context{} = ctx) do
    fields = %{
      "variable" => Kino.SmartCell.prefixed_var_name("client", attrs["variable"]),
      "url" => attrs["url"] || "http://localhost:4000/api"
    }

    ctx = Context.assign(ctx, fields: fields)

    {:ok, ctx}
  end

  @impl Kino.JS.Live
  def handle_connect(%Context{} = ctx) do
    initial_attrs = %{
      fields: ctx.assigns.fields,
      action: :handle_connect
    }

    {:ok, initial_attrs, ctx}
  end

  @impl Kino.SmartCell
  def to_attrs(%Context{} = ctx) do
    # TODO: figure out what this does.
    # GUESS: it turns Context into a map to send to the frontend?
    Map.merge(ctx.assigns, %{action: :to_attrs})
  end

  @impl Kino.SmartCell
  def to_source(%{fields: fields} = assigns_from_to_attrs) do
    # is attrs the result of "to_attrs/1" ??

    variable = fields["variable"]
    url = fields["url"]

    if not is_variable_valid?(variable) do
      raise "GraphqlSmartCell.ClientCell expects a valid variable name, but got: #{inspect(variable)} - attrs: #{inspect(assigns_from_to_attrs)}"
    end

    if not is_url_valid?(url) do
      raise "GraphqlSmartCell.ClientCell expects a valid url, but got: #{inspect(url)} - attrs: #{inspect(assigns_from_to_attrs)}"
    end

    # valid elixir source code
    """
    #{variable} = #{inspect(__MODULE__)}.do_the_work(#{inspect(url)})
    """
  end

  def do_the_work(url) do
    AbsintheClient.attach(Req.new(base_url: url))
  end

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
    # update variable name only if it is valid.
    if is_variable_valid?(value) do
      %{"variable" => value}
    else
      %{"variable" => fields["variable"]}
    end
  end

  defp to_updates(fields, "url", value) do
    # only update url if it is a "complete" url
    if is_url_valid?(value) do
      %{"url" => value}
    else
      %{"url" => fields["url"]}
    end
  end

  defp is_variable_valid?(value) do
    # calls into the deep magic :elixir_config
    is_binary(value) && Kino.SmartCell.valid_variable_name?(value)
  end

  defp is_url_valid?(value) when is_binary(value) do
    # this check might need a more "complete" implementation.
    uri = URI.parse(value)

    !(uri.scheme == nil || uri.host == nil)
  end

  defp is_url_valid?(_), do: false
end
