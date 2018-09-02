# This module identifies duplicate files within a directory tree, shows them,
# and when told to do so, deletes them.
# Syntax: Deduper.find_dups(path, ftypes)
# Author: Rogue H0F

defmodule Deduper do # Start of module
  @moduledoc """
  Documentation for Deduper.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Deduper.hello
      :world

  """

  # MAIN PROCESS
  def find_dups(path \\ "/Users/rogier/Dropbox/Camera Uploads/2012",
    ftypes \\ "jpg,jpeg,gif,png,tif,tiff,pic,pict,bmp") do

    # TODO: Make options Image, Movie, Audio, ..., All, Other to create extensions
    # ...where All is *.* wildcard, and Other checks third variable for
    # ...provided extensions by user (i.e. Deduper.find_dups/3).

    # TODO: check_path(path)
    # TODO: check_ftypes(ftypes)

    IO.puts "Path: #{path}. (Absolute path: don't forget the slash at the beginning.)"
    IO.puts "Extensions to look for: #{ftypes} ."

    wildcard = "#{path}/**/*.{#{ftypes},#{String.upcase(ftypes)}}"  # Create string for Path.wildcard
    start_time = System.monotonic_time(:millisecond)                # Start the VM clock

    # MAIN
    File.cd!(path, fn ->
      # TODO: Path.wildcard("#{path}/**/*.{#{ftypes}}")
      # ...maybe with wildcard = "#{path}/**/*.{#{ftypes},#{String.upcase(ftypes)}}"
      # ...Path.wildcard("#{wildcard}")
      Path.wildcard("#{wildcard}")                                  # Show all relevant files in tree
      |> Enum.filter( fn(filename) -> File.regular?(filename) end)  # Weed out dead links, etc.

      |> Enum.group_by( fn(filename) ->                             # Calc sha256 per file, and group 'm.
           "#{ :crypto.hash( :sha256, File.read!("#{filename}") ) |> Base.encode16 }"
          end)
      # Next, filter on hashes with more than 1 associated file (>1 element in the list)
      |> Enum.filter( fn {_hash, files} -> length(files) > 1 end)   # Filter on hash with multiple files
      |> Enum.each( fn {_hash, files} ->                            # For each cluster of duplicates do...

            IO.puts "--- Start of #{ Enum.count(files) } duplicate files ---"
            # TODO: While length(files) > 1 AND user_input <> do_nothing do...
            #   ask which file may be deleted, rinse and repeat
            duplicates = Enum.with_index(files, 1)
            IO.puts "Inspect duplicates: #{inspect duplicates}"
            Enum.each(duplicates, fn { filename, index} ->
              IO.puts"#{index} - #{filename}" end)

            total_size =
              Enum.count(files, fn(filename) ->
                  IO.puts "#{inspect File.stat!(filename).size} ..."
                end)

            IO.puts "--- End of duplicate files (total size #{total_size} bytes ---"

          end)

      # |> Enum.reduce( %{}, fn(filename, acc) ->                     # Create new map
      #       Map.put(acc, filename,                                  # Key = (unique) filename
      #         {                                                     # Value = tuple with...
      #           "#{inspect File.stat!(filename).ctime}",            # file creation datetime
      #           "#{inspect File.stat!(filename).size}",             # filesize and hash (sha256)
      #           "#{:crypto.hash( :sha256, File.read!("#{filename}") ) |> Base.encode16}"
      #         }
      #       )
      #    end)

    end)

    # used_time = stop_time - start_time in milliseconds
    stop_time = System.monotonic_time(:millisecond)
    diff = stop_time - start_time
    IO.puts "Processing took #{ diff/1000 } seconds."

  end

  # Returns path if path given is a valid directory
  # If no path is given, ask for the pathname to start the search for duplicate files
  # def path_given(path \\ "") do
  #   path =
  #   case path do
  #     "" ->
  #       IO.puts "The path is the root of the directory-tree you want to check for duplicate files."
  #         IO.gets "Please enter the path: "
  #         |> String.trim
  #     path ->
  #       check_path(path)
  #       path
  #   end
  # end

  # Check validity of path-variable as a valid directory, returns path when valid, or exit..
  # When no path is passed, it will return the current working directory as default.
  def check_path(path \\ ".") do
    case File.dir?(path) do
      true  ->
        IO.puts "Going to read directory-tree from path: #{path}. Please take a cup of tea."
        path
      false ->
        exit("Sorry, path #{path} does not exist (as a directory). Please provide a valid path.")
    end
  end

  # TODO: Aks for specific file-extensions to search for (so more than duplicate images can be handled).

  # The wrapper provides Start and Stop information around a process
  # def process_wrapper(option \\ "start") do
  #   case option do
  #     "start" ->
  #       start_time = DateTime.utc_now
  #       IO.puts "----------  #{String.upcase(option)} (time UTC = #{start_time}) ----------"
  #     "stop" ->
  #       stop_time = DateTime.utc_now
  #       IO.puts "----------  #{String.upcase(option)} (time UTC = #{stop_time}, start was #{start_time}) ----------"
  #       # TODO: Substract stop_time from start_time and show duration.
  #   end
  # end


  def read_dirtree_0(path \\ "/Users/rogier/Dropbox/Camera\ Uploads/2012") do
  # by default, choose given path after \\ when started without a provided path-variable

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
          exit(:boom)

      end

      cyphermap =
        Enum.reduce(filenames, %{}, fn(filename, acc) ->
            Map.put(acc, filename,
              :crypto.hash( :sha256, File.read!("#{filename}") ) |> Base.encode16 )
        end)

        IO.inspect cyphermap

  end





### READ, UNDERSTAND IN AWE, LEARN AND APPLY...    ;-)  #######################################

# This snippet of code traverses a directory tree,
#  and returns a list of duplicate files, with creation-date and file-size (in bytes).
# Source: https://rosettacode.org/wiki/Find_duplicate_files .
# Author: Pearl24 (=?)


  # Provides a list of all duplicate files in directory "dir", and its subdirs.
  # Take path (dir) as input, or take the current dir is default
  def rosetta_find_duplicate_files(dir \\ "/Users/rogier/Dropbox/Camera Uploads/2012") do
    # Show the directory it will traverse.
    IO.puts "\nDirectory : #{dir} (Don't forget the slash at the beginning.)"
    # CD to DIR (if necessary, or stay in current dir), and execute the function on that directory
    # (and return to the previous directory).
    File.cd!(dir, fn ->
      # Filter the output on the "File.ls!" command on real files
      # "File.regular?" returns TRUE if fname points to a file, or to a valid link (pointing to a file).
      Enum.filter(File.ls!, fn fname -> File.regular?(fname) end)
      # Groups the filelist by the function in group_by, in this case filesize,
      # where the command File.stat! returns file related info (as tuple),
      # and .size returns the filesize (from that tuple).
      |> Enum.group_by(fn file -> File.stat!(file).size end)
      # Filter the ordered list, so only files with filesize > 1 byte will remain.
      |> Enum.filter(fn {_, files} -> length(files)>1 end)
      # Perform the following function on each of the remaining files...
      |> Enum.each(fn {size, files} ->
           # ... Group all files (by reading them and calculating) their hash MD5 value
           Enum.group_by(files, fn file -> :erlang.md5(File.read!(file)) end)
           # CHECK WHAT THE NEXT LINE DOES (AND ALSO ABOVE THIS LINE)!!
           |> Enum.filter(fn {_, files} -> length(files)>1 end)
           #  For each MD5 - file combination, do the following...
           |> Enum.each(fn {_md5, fs} ->
                # Print separator line]
                IO.puts "  --------------------------------------------"
                # Print each pair of duplicate files;
                # Last modification time (as tuple), size, and filename
                Enum.each(fs, fn file ->
                  IO.puts "  Last modification & size: #{inspect File.stat!(file).mtime}\t#{size} File: #{file}"
                end)
              end)
         end)
    end)
  end

end # End of module

