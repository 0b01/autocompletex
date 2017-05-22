# Autocompletex
----

![hex.pm](https://img.shields.io/hexpm/v/autocompletex.svg)

Autocompletex is a low-latency plug-and-play autocomplete tool using Redis sorted set. Written in pure Elixir, it focuses on rapid prototyping using your existing stack: simply start a redis instance, and start_link a GenServer.

Currently, it provides these implementation:

* Google-like query prediction based on popularity. E.G. ne -> netflix, new york times 
* Lexicographic. Sorted in alphabetical order (faster)

There are two ways to run it:

* Use it as a standalone microservice with HTTP connection.
* GenServer

## Installation
--------

Add the `:autocompletex` to your `mix.ecs` file:

```elixir
def deps do
  [{:autocompletex, "~> 0.1.0"}]
end
```

Then add it to `applications`:

```elixir
defp application() do
  [applications: [:logger, :redix]]
end
```

Then, run mix deps.get in your shell to fetch the new dependency.


## Usage
--------

Using `autocompletex` is very simple.

### Overview

There are several ways to run it.

1. Standalone HTTP service
2. GenServer
3. Supervisor tree

### Manual

To start a GenServer manually:

```elixir
# For Lexicographic:
{:ok, conn} = Redix.start_link
db = "testdb"
{:ok, worker} = Autocompletex.Lexicographic.start_link(conn, db, Autocompletex)

# For Predictive:
{:ok, conn} = Redix.start_link
{:ok, worker} = start_link(conn, :ac)
```

Alternatively, you can use it in a supervision tree.

Add this to `config.exs`:

```elixir
config :autocompletex,
  redis_host: "localhost",
  redis_port: 6379,
  redis_string: nil,
  http_server: true,
  http_port: 3000,
  debug: false, # runs :observer.start if true
  type: :lexicographic #:predictive
```

Then you can simply call

```elixir
Autocompletex.Lexicographic.upsert(Autocompletex.Lexicographic, ["test", "example"])
```

If `http_server` is set to `true`, two http endpoints will be accessible at the designated `http_port`(default: 3000).

```
upsert   -> /add?term=Elixir
complete -> /complete?term=te
```

## API
----

There are two functions: `upsert` and `complete`.

`upsert/2` means insert or update. For Lexicographic, if a query is already inserted, it will do nothing. For Predictive, it will increment the score of the query.

`complete/3` returns a list of matched results. It takes 3 parameters: `pid`, `prefix`, `rangelen`. rangelen is the number of results to be returned. Defaults to 50.


```elixir
:ok = Autocompletex.Lexicographic.upsert(worker, ["test", "example"])
{:ok, val} == complete(worker, "te") # assert val == ["test"]
```

## Misc
------

If you have a list of user-generated search queries, you can use a mix task to index and provision the redis instance.

Simply do: `mix autocompletex.import --filename [fname] [--predictive]`

`--predictive` is a boolean flag.

## Docs

To be updated. In the meantime, I'm happy to answer questions in issues.