# GraphqlSmartCell

A Livebook Smart Cell designed to run GraphQL queries

## Description

Built on [`AbsintheClient`](https://hexdocs.pm/absinthe_client/AbsintheClient.html), this project provides two cells:

  * Client cell
  * Query cell

The client cell uses `AbsintheClient` to build a [`Req`](https://hexdocs.pm/req/0.3.0/Req.html) struct with the proper credentials necessary to hit a GraphQL API. We use [rickandmortyapi.com](https://rickandmortyapi.com) in our examples.

The query cell takes the output of the client cell and runs the query.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `graphql_smart_cell` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:graphql_smart_cell, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/graphql_smart_cell>.

## Usage

See the guide in the docs.

## Screenshots

### Client cell

<img src="https://user-images.githubusercontent.com/168677/196064401-fd0eac29-98ba-4263-8a9d-6b0acea8e23b.png">

### Query cell

<img src="https://user-images.githubusercontent.com/168677/196064395-a663987c-a34e-4177-8bbc-b67512faae02.png">

## The "dream"

<img src="https://user-images.githubusercontent.com/10274508/196064112-558e4d5f-1f7e-452e-81b6-89d1e3f30419.png">

At one point, we had GraphiQL powering our cells.
Consider this a cautionary tale in relying on JavaScript!