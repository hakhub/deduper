defmodule Deduper do # Start of module

  @moduledoc """
  Documentation for Deduper.
  This module identifies duplicate files within a directory tree, shows them,
  and (when it's programmed ;-) will delete selected duplicates, when told to do so.
  Syntax:           Deduper.find_dups( path, option, [extension(s)] ), 
                    where path is the root of the directory-tree to be traversed
                    (absolute path: don't forget the slash at the beginning.)
                    where option = audio, document, image, video, all or other (other uses the extensions).
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
    IO.puts "==== COMMAND INFO ========"
    IO.puts "#{@moduledoc}"

    IO.puts "==== USER CONFIG INFO ===="
    IO.puts "Path (the root of the tree): #{path} ."
    IO.puts "Extensions to look for (option: #{option}): #{ftypes} ."
    IO.puts "Please take a cup of tea..."

    # This line creates the wildcard that defines what files to look for...
    wildcard = "#{path}/**/*.{#{ftypes},#{String.upcase(ftypes)}}"  # Create string for Path.wildcard

    # This line for process timing purposes, starting the timer...
    start_time = System.monotonic_time(:millisecond)                # Start the VM clock/timer

    # MAIN ###
    IO.puts "==== PROGRESS INFO ======="
    IO.puts "... change directory to path..."
    File.cd!(path, fn ->
      # TODO: Path.wildcard("#{path}/**/*.{#{ftypes}}")
      # ...maybe with wildcard = "#{path}/**/*.{#{ftypes},#{String.upcase(ftypes)}}"
      # ...Path.wildcard("#{wildcard}")
      IO.puts "... performing directory tree walktrough..."
      Path.wildcard("#{wildcard}")                                  # Show all relevant files in tree
      #IO.puts "... calculating hash per file, and clustering..."
      |> Enum.filter( fn(filename) -> File.regular?(filename) end)  # Weed out dead links, etc.
      |> Enum.group_by( fn(filename) ->                             # Calc hash per file, and group 'm.
           # Performance info: MD5 takes approx 54%, of the time SHA256 takes on the same 548 files, but SHA256 is more thourough.
           "#{ :crypto.hash( :md5, File.read!("#{filename}") ) |> Base.encode16 }"
           # "#{ :crypto.hash( :sha256, File.read!("#{filename}") ) |> Base.encode16 }"
          end)
      # Next, filter on hashes with more than 1 associated file (>1 element in the list)
      #IO.puts "... clustering files with same hash..."
      |> Enum.filter( fn {_hash, files} -> length(files) > 1 end)   # Filter on hash with multiple files
      |> Enum.each( fn {_hash, files} ->                            # For each cluster of duplicates do...

          # DO SOMETHING WITH THE DUPLICATES FOUND...
          nr_of_dups = Enum.count(files)
          IO.puts "--- Start of #{ nr_of_dups } duplicate files ---"
          duplicates = Enum.with_index(files, 1)                  # Add an index-nr to each duplicate
          Enum.each(duplicates, fn { filename, index} ->
              IO.puts"#{index} - #{filename}"
            end)
          # TODO: Select files for deletion, renaming, printing, encrypting, reverse engineering or whatnot...
          # Pseudo code:
          # WHILE length(files) > 1 AND user_input <> do_nothing DO...
          #   ask which file may be deleted, rinse and repeat
          IO.puts "--- End of duplicate files  ---"

        end) # end of Enum.each
      end) # end of File.cd!

    # END ###
    # This part provides end-of-process information
    # used_time = stop_time - start_time in milliseconds
    stop_time = System.monotonic_time(:millisecond)                 # Read process end-time of VM clock/timer
    diff = stop_time - start_time                                   # Process-time is difference between start- and end-time
    elapsed_seconds = diff/1000
    elapsed_minutes = Float.floor( diff/60_000, 2)
    elapsed_hours   = Float.floor( diff/3_600_000, 2)
    IO.puts "==== END INFO ============"
    IO.puts "Processing took #{ elapsed_seconds } seconds, roughly #{ elapsed_minutes } minutes or #{ elapsed_hours } hours."
    IO.puts ".oOo."

  end # End of find_dups function
end # End of module
