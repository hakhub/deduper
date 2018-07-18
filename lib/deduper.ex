# ==== Copy from https://rosettacode.org/wiki/Find_duplicate_files ====

defmodule Deduper do
  @moduledoc """
  Documentation for Deduper.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Deduper.hello
      :world

  """
  def find_duplicate_files(dir) do
    IO.puts "\nDirectory : #{dir}"
    File.cd!(dir, fn ->
      Enum.filter(File.ls!, fn fname -> File.regular?(fname) end)
      |> Enum.group_by(fn file -> File.stat!(file).size end)
      |> Enum.filter(fn {_, files} -> length(files)>1 end)
      |> Enum.each(fn {size, files} ->
           Enum.group_by(files, fn file -> :erlang.md5(File.read!(file)) end)
           |> Enum.filter(fn {_, files} -> length(files)>1 end)
           |> Enum.each(fn {_md5, fs} ->
                IO.puts "  --------------------------------------------"
                Enum.each(fs, fn file ->
                  IO.puts "  #{inspect File.stat!(file).mtime}\t#{size}  #{file}"
                end)
              end)
         end)
    end)
  end
end

hd(System.argv) |> Files.find_duplicate_files