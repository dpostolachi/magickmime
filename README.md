# Magickmime

Guess MIME type by file signatures.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `magickmime` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:magickmime, "~> 0.1.0"}
  ]
end
```


## Example

Works only with BitStrings, a length of 12 bytes should be enough to check all the supported mime types.

```elixir
{ :ok, file } = File.open( "test/image.png", [ :read ] )
data = IO.binread( file, :all )
mime( data )
:png
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/magickmime](https://hexdocs.pm/magickmime).

