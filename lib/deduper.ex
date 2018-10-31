defmodule Deduper do # Start of module

  @moduledoc """
  Documentation for Deduper.
  This module identifies duplicate files within a directory tree, shows them,
  and (when it's programmed ;-) will delete selected duplicates, when told to do so.
  Syntax:           Deduper.find_dups(path, ftypes)
  Author:           Rogue
  Lango:            Elixir
  File-tree:        deduper (folder with file-tree)
  Contributors:     Search in the comments for TODO to see where you can contribute.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Deduper.hello
      :world

  """

  # MAIN PROCESS
  def find_dups(path \\ ".", option \\ "all") do

    # TODO: Make options Image, Movie, Audio, ..., All and Other to define extensions,
    # ...where All is the catch-all *.* wildcard, and Other checks third variable for
    # ...provided extensions by user (i.e. Deduper.find_dups/3).

    # TODO: check_path(path)
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

    # TODO: check_ftypes(ftypes)

    IO.puts "Options are: audio, document, image, video, all (default is all)."
    option = "all"

    # TODO: check available extensions for various file formats
    # TODO: complete options
    ftypes =
      case option do
        # Avoid spaces between extensions (spaces are taken litterally by Path.wildcard).
        # For most common extensions, see https://www.computerhope.com/issues/ch001789.htm ...
        # ...and https://fileinfo.com/filetypes/common
        "audio"       -> "mp3,aac,aif,aiff,wav"
        "document"    -> "doc,docx,ppt,pptx,xls,xlsx,pdf,txt,rtf,tex,odt"
        "image"       -> "jpg,jpeg,gif,png,tif,tiff,pic,pict,bmp"
        "video"       -> "3g2,3gp,avi,flv,h264,m4v,mkv,mov,mp4,mpeg,qt,vid,wmv"
        "all"         -> "*"
        _             -> "*"
      end

    # This part provides process config information...
    IO.puts "==== COMMAND INFO ===="
    IO.puts "Path: #{path}. (Absolute path: don't forget the slash at the beginning.)"
    IO.puts "Extensions to look for (option #{option}): #{ftypes} ."

    # This line creates the wildcard that defines what files to look for...
    wildcard = "#{path}/**/*.{#{ftypes},#{String.upcase(ftypes)}}"  # Create string for Path.wildcard

    # This line for process timing purposes, starting the timer...
    start_time = System.monotonic_time(:millisecond)                # Start the VM clock/timer

    # MAIN
    IO.puts "==== PROGRESS INFO ===="
    IO.puts "... change directory to path..."
    File.cd!(path, fn ->
      # TODO: Path.wildcard("#{path}/**/*.{#{ftypes}}")
      # ...maybe with wildcard = "#{path}/**/*.{#{ftypes},#{String.upcase(ftypes)}}"
      # ...Path.wildcard("#{wildcard}")
      IO.puts "... performing directory tree walktrough..."
      Path.wildcard("#{wildcard}")                                  # Show all relevant files in tree
      #IO.puts "... calculating hash per file, and clustering..."
      |> Enum.filter( fn(filename) -> File.regular?(filename) end)  # Weed out dead links, etc.
      |> Enum.group_by( fn(filename) ->                             # Calc sha256 per file, and group 'm.
           # MD5 takes #{ (4088/7606) * 100}%, approx 54%, of the time SHA256 takes on 548 files."
           "#{ :crypto.hash( :md5, File.read!("#{filename}") ) |> Base.encode16 }"
           # "#{ :crypto.hash( :sha256, File.read!("#{filename}") ) |> Base.encode16 }"
          end)
      # Next, filter on hashes with more than 1 associated file (>1 element in the list)
      #IO.puts "... clustering files with same hash..."
      |> Enum.filter( fn {_hash, files} -> length(files) > 1 end)   # Filter on hash with multiple files
      |> Enum.each( fn {_hash, files} ->                            # For each cluster of duplicates do...

            nr_of_dups = Enum.count(files)
            IO.puts "--- Start of #{ nr_of_dups } duplicate files ---"
            # TODO: While length(files) > 1 AND user_input <> do_nothing do...
            #   ask which file may be deleted, rinse and repeat
            duplicates = Enum.with_index(files, 1)                  # Add an index-nr to each duplicate
            IO.puts "Inspect duplicates: #{inspect duplicates}"
            Enum.each(duplicates, fn { filename, index} ->
                IO.puts"#{index} - #{filename}"
              end)

            # TODO: (nr_of_dups - 1) * file-size of duplicates can be freed
            # total_size =
            #   Enum.sum(
            #     Enum.each(files, fn(filename) -> File.stat!(filename).size end)
            #   end)
            # IO.puts "--- End of duplicate files (total size #{total_size} bytes) ---"
            IO.puts "--- End of duplicate files  ---"

          end) # end of Enum.each

    end) # end of File.cd!

    # used_time = stop_time - start_time in milliseconds
    stop_time = System.monotonic_time(:millisecond)                 # Read process end-time of VM clock/timer
    diff = stop_time - start_time                                   # Process-time is difference between start- and end-time
    IO.puts "Processing took #{ diff/1000 } seconds, roughly #{ Float.floor( diff/60_000, 2) } minutes."

  end

  # Check validity of path-variable as a valid directory, returns path when valid, or exit..
  # When no path is passed, it will return the current working directory as default.
  def check_path(path \\ ".") do
    case File.dir?(path) do
      true  ->
        IO.puts "Going to read directory-tree from path: #{path}. Please take a cup of tea."
        path
      false ->
        exit("Sorry, the path #{path} does not exist (as a directory). Please provide a valid path.")
    end
  end

end # End of module
