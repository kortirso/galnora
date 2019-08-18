# Galnora

GenServer for translating words or phrases in background mode with Elixir.
You can use this server as separate application or include it in your Phoenix project.

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

## Usage

### Add job to Galnora server

By adding job to server you starts separate process as background job.

```elixir
Galnora.Server.add_job(sentences, job_attrs)
```

#### Options

    sentences - list of tuples for translation, like [{uid, input}, ...]
        uid - identificator, string
        input - text for translation, string
    job_attrs - attributes for job as map
        uid - identificator, string
        type - type of translating service, atom, available [:systran]
        from - source language, ISO 639-1 format (like "en"), string
        to - target language, ISO 639-1 format (like "ru"), string
        keys - map for keys, for example, for Systran - %{key: "API_KEY"}


### Get job from Galnora server by uid

Get job information from server. Status of job can be active, completed or failed.

```elixir
Galnora.Server.get_job(job_uid)
```

#### Options

    job_uid - identificator for job


### Get job's sentences from Galnora server by job's uid

You can get results of translation.

```elixir
Galnora.Server.get_job_with_sentences(job_uid)
```

#### Options

    job_uid - identificator for job


### Delete job from Galnora server by uid

If job is completed or failed you can just delete it with all sentences.

```elixir
Galnora.Server.delete_job(job_uid)
```

#### Options

    job_uid - identificator for job


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kortirso/galnora.

## License

The package is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Disclaimer

Use this package at your own peril and risk.

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/galnora](https://hexdocs.pm/galnora).

