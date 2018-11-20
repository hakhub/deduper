# Deduper


# Documentation for Deduper.

This module identifies duplicate files within a directory tree, shows them, and (when it's programmed ;-) will delete selected duplicates, when told to do so.

# Syntax

Deduper.find_dups( path, option, [extension(s)] )

Where:
* path is the root of the directory-tree to be traversed (absolute path: don't forget the slash at the beginning.)
* option = audio, document, image, video, all or other (other uses the extensions).


# Contributors are invited

Fork, search in the comments for TODO to see where you can contribute, and send a Pull-request when you're ready to show the world your beautiful code-art.

:smile:

# Boilerplate

Author:           Rogue (github handle Rogue-1, email roque@froodi.com)
Lango:            Elixir 1.7.3
File-tree:        deduper (folder with file-tree)

# Miscellaneous info

The text below is default text when generating a new project with mix.
When useful, I will make Deduper a Hex package.


**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `deduper` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:deduper, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/deduper](https://hexdocs.pm/deduper).

