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

# read_dirtree(path)        # input path,
                            #output map with all filenames in the dir-tree starting at path

# parse_dirtree(filelist)   # input list (i.e. map) of all filenames,
                            # output map of tuples in the folowing form:
                            # { fullname(i.e. path/filename, filename, fingerprint (i.e. hash-value) }

# check_duplicates(parses)  # input parse_list (i.e. map of tuples)
                            # output list of grouped duplicate-files (i.e. sets of duplicates)

  def read_dirtree_0(path \\ "/Users/rogier/Dropbox/Camera\ Uploads/2007") do
  # by default, choose given path after \\ when started without a provided path-variable

    # check validity of path-variable as a valid directory.
    case File.dir?(path) do
      true -> IO.puts "Reading directory-tree from path: #{path}. Please take a cup of tea."
      false -> IO.puts "Sorry, path #{path} does not exist (as a directory). Please provide a valid path."
    end

    # run directory-tree from path and all sub-dirs
    filenames =
      case {result, exitstatus} = System.cmd("find", [path, "-name", "*.jpg", "-print"], []) do
        {result, 0} ->
          IO.puts "List of filenames has been generated. (Exitstatus 0 from find-command.)"
          result |> String.split("\n")
        {_, exitstatus} ->
          IO.puts "Exitstatus ERROR: #{exitstatus}"
          ["ERROR"]
      end

      IO.puts "Filenames = ", filenames
      IO.puts "End of filenames ====="
      filenames

    # iterates over filenames and creates a unique hash/cypher from (the contents) of each file
    files_fingerprints =
      case filenames do
        ["ERROR"] ->
          IO.puts "No files found. Sorry."
          ["EMPTY LIST"]
        filenames ->
          # EXAMPLE: lijst = Enum.reduce( 1..25, %{}, fn(x, acc) -> Map.put(acc, x, x*x) end)
          Enum.reduce(filenames, %{}, fn(filename, acc) ->
            Map.put(acc, filename,
              { :crypto.hash( :sha256, File.read!("#{filename}") ) |> Base.encode16} )
          end)
      end

      IO.puts "Map of files + cipher = ", files_fingerprints

  end

  def read_dirtree_1(path \\ "/Users/rogier/Dropbox/Camera\ Uploads/2007") do

    Enum.each(File.ls!(path), fn file ->
      IO.puts "-----------------------------------------------"
      fullname = "#{path}/#{file}"
      IO.puts "Fullname (path/filename) = #{path}/#{file}"
      if File.dir?(fullname), do: read_dirtree_1(fullname)
      IO.puts "Hashvalue: #{:crypto.hash(:sha256, File.read!("#{fullname}") ) |> Base.encode16}"
      # Zorg dat dit wordt toegevoegd aan een map, die uiteindelijk
      # met alle filenames in de tree als output dient
      IO.puts "+++"
    end)

  end

  def read_dirtree_3(_path \\ ".") do

    path = "/Users/rogier/Dropbox/Camera\ Uploads/2015"

    IO.puts "Reading directory-tree from path: #{path}. Please take a cup of tea."

    {findresult, exitstatus} = System.cmd("find", [path],[]); output = findresult |> String.split("\n")
    IO.puts "Exitstatus = #{exitstatus}"

    Enum.each(output, fn (line) -> IO.puts "File: #{line}." end)

  end


  def find_duplicate_files(dir \\ ".") do
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

# hd(System.argv) |> Deduper.find_duplicate_files