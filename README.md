# A show-duplicates script called "Deduper", in Elixir code

## Introduction

Rogue-1 is my public repository, aimed at improving my programming skills and sharing code-art for public use.

Tips, comments and forks that can improve the usefulness of this code and/or my programming skills are more than welcome.

Enjoy! :smile:


# Documentation for Deduper.

## Purpose

This module identifies duplicate files within a directory tree.
It groups them, and shows/lists them in an orderly fashion.

** PLEASE NOTE: Process may take al lot of time, due to the fact that each file is checked using a hash-mechanism. **

## Syntax

`Deduper.find_dups( "path", "option", ["extension(s)"] )`

Where:
* `path` is the root of the directory-tree to be traversed (absolute path: don't forget the slash at the beginning.)
* `option` can be _audio, document, image, video, all_ or _other_ (where _other_ uses the extensions you define).
* `extensions` is **optional**, and are the file-extensions you want to search for. Note: extensions **separated by comma's**, and **no spaces**.

Example: `Deduper.find_dups( "/.", "other", "html,css" )` # This will search for HTML and CSS files in the tree starting at the current directory.

## Comments

Extensive comments are added to explain code syntax (yep, also for myself) and can be used for learning Elixir.

If you enjoy the pains of programming, please read the `git log` as well. :wink:


# Contributors are invited

Fork, search in the comments for TODO to see where you can contribute, and send a Pull-request when you're ready to show the world your beautiful code-art.

:+1:


# Boilerplate

Author: Rogier "Rogue Foh" Hof (:octocat: handle **Rogue-1**, email **rogue@froodi.com** (read infrequently, response not guaranteed))

Lango: Elixir 1.7.3

File-tree: deduper (folder with file-tree)


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


.oOo.