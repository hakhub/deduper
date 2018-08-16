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

  def read_dirtree_0(path \\ "/Users/rogier/Dropbox/Camera\ Uploads/2012") do
  # by default, choose given path after \\ when started without a provided path-variable

  starttime = DateTime.utc_now
  IO.puts "START: The time is #{starttime}."

    # check validity of path-variable as a valid directory.
    case File.dir?(path) do
      true  -> IO.puts "Step 1: Reading directory-tree from path: #{path}. Please take a cup of tea."
      false -> IO.puts "Step 1: Sorry, path #{path} does not exist (as a directory). Please provide a valid path."
    end

    # Find all files in directory-tree, starting from from path, and all sub-dirs
    # Only select files with the designated extensions (!) Change when required!
    # Note: The find-command works only on UNIX variants, and has only been tested on OS/X High Sierra
    {result, exitstatus} =
      System.cmd("find", ["-E", path, "-regex", ".*\.(jpg|jpeg|gif|png|tif|tiff|pic|pict)"], [])
      #System.cmd("find", ["-E", path, "-regex", ".*\.(gif|png|tif|tiff|pic|pict)"], [])

      IO.puts "Inspecting output..."
      IO.inspect result

    filenames =
      case exitstatus  do

        # Succesful execution of directory walkthru (find-command).
        0 ->
          IO.puts "Step 2: Succesful directory walkthru. (Exitstatus 0 from find-command.) Creating map with filenames."
          # Create List out of result of find-command
          result
            |> String.split("\n")
            # The next adds a filename, and substracts an empty line (which is a dirty solution
            # cleaning empty lines/blanks from the list. (Because add only if not empty does not work !?)
            # More specific: Enum.reduce BlaBla if filename != "" do BlaBla does not process the != check.
            |> Enum.reduce( [], fn(filename, acc) -> acc ++ ["#{filename}"] -- [""] end)

        # UNsuccesful execution of directory walkthru.
        _ ->
          IO.puts "Step 2: Problem with directory walkthru. (Exitstatus not 0 (ERROR) from find-command.) No files found."

      end

      cyphermap =
        Enum.reduce(filenames, %{}, fn(filename, acc) ->
            Map.put(acc, filename,
              :crypto.hash( :sha256, File.read!("#{filename}") ) |> Base.encode16 )
        end)

        IO.inspect cyphermap

      finishtime = DateTime.utc_now
      IO.puts "FINISH: The time is #{finishtime}."
      #IO.puts "The processing took #{finishtime - starttime}. Amazing, huh!?"

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