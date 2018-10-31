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

  ### MAIN PROCESS ###
  def find_dups(path \\ ".", option \\ "all", extensions \\ "") do

    # START ###
    # Checks if path is a valid path (i.e. exists).
    case File.dir?(path) do
      true  ->
        path
      false ->
        exit("ERROR: Sorry, the path #{path} does not exist, or is no directory. Please provide a valid path.")
    end

    # This part provide info and sets the extensions to search for (based on the chosen option, or the default)
    # TODO: check available extensions for various file formats
    IO.puts "Options are: audio, document, image, video, all or other."
    IO.puts "Default is all, while the option other uses the provided extensions (without a check)."

    ftypes =
      case option do
        # Avoid spaces between extensions (spaces are taken litterally by Path.wildcard).
        # TODO: Check and complete related file extensions for each option (audio, image, etc.)
        # For most common extensions, see https://www.computerhope.com/issues/ch001789.htm ...
        # ...and https://fileinfo.com/filetypes/common
        "audio"       -> "mp3,aac,aif,aiff,wav"
        "document"    -> "doc,docx,ppt,pptx,xls,xlsx,pdf,txt,rtf,tex,odt"
        "image"       -> "jpg,jpeg,gif,png,tif,tiff,pic,pict,bmp"
        "video"       -> "3g2,3gp,avi,flv,h264,m4v,mkv,mov,mp4,mpeg,qt,vid,wmv"
        "other"       -> extensions   # This enables the user to enter her own extensions, using the option "other"
        "all"         -> "*"
        _             -> "*"
      end

    # This part provides process config information...
    IO.puts "==== COMMAND INFO ===="
    IO.puts "Path (the root of the tree): #{path} ."
    IO.puts "(Absolute path: don't forget the slash at the beginning.)"
    IO.puts "Extensions to look for (option #{option}): #{ftypes} ."
    IO.puts "Please take a cup of tea..."

    # This line creates the wildcard that defines what files to look for...
    wildcard = "#{path}/**/*.{#{ftypes},#{String.upcase(ftypes)}}"  # Create string for Path.wildcard

    # This line for process timing purposes, starting the timer...
    start_time = System.monotonic_time(:millisecond)                # Start the VM clock/timer

    # MAIN ###
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

    # END ###
    # This part provides end-of-process information
    # used_time = stop_time - start_time in milliseconds
    stop_time = System.monotonic_time(:millisecond)                 # Read process end-time of VM clock/timer
    diff = stop_time - start_time                                   # Process-time is difference between start- and end-time
    IO.puts "==== END INFO ===="
    IO.puts "Processing took #{ diff/1000 } seconds, roughly #{ Float.floor( diff/60_000, 2) } minutes."
    IO.puts ".oOo."

  end # End of find_dups function

end # End of module
