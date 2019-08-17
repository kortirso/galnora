# Galnora

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `galnora` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:galnora, "~> 0.0.1"}
  ]
end

def application do
  [
    extra_applications: [..., :galnora]
  ]
end
```

## Mnesia Setup

To persist messages across application restarts, specify the DB path in your `config.exs`:

```elixir
config :mnesia, dir: 'mnesia/#{Mix.env}/#{node()}' # Notice the single quotes
```

And run the following mix task:

```bash
mix galnora.setup

MIX_ENV=test mix galnora.setup
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/galnora](https://hexdocs.pm/galnora).

