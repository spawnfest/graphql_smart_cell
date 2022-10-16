import "https://unpkg.com/react@17.0.2/umd/react.development.js"
import "https://unpkg.com/react-dom@17.0.2/umd/react-dom.development.js"
import "https://unpkg.com/graphiql@2.0.9/graphiql.min.js"


export function init(ctx, payload) {
  ctx.importCSS("main.css");
  ctx.importCSS(
    "https://fonts.googleapis.com/css2?family=Inter:wght@400;500&display=swap"
  );
  ctx.importCSS(
    "https://unpkg.com/graphiql/graphiql.min.css"
  );

  const fetcher = GraphiQL.createFetcher({
    url: "https://rickandmortyapi.com/graphql"
  });

  ReactDOM.render(
    React.createElement(
      GraphiQL.React.GraphiQLProvider, {
        fetcher: fetcher,
        response: JSON.stringify(payload, null, 2)
      },
      React.createElement(
        "div", {
          className: "graphiql-container"
        },
        React.createElement(
          "div", {
            className: "graphiql-response"
          },
          React.createElement(
            GraphiQL.React.ResponseEditor, {}
          )
        )
      )
    ),
    ctx.root
  )
}