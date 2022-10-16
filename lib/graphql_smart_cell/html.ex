defmodule GraphqlSmartCell.HTML do
  use Kino.JS

  def new(html) do
    Kino.JS.new(__MODULE__, html)
  end

  asset "main.js" do
    """
    export function init(ctx, html) {
      ctx.root.innerHTML = html;
    }
    """
  end
end
