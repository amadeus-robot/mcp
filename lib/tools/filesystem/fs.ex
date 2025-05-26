# File: lib/mcp_server/tools/fs_ls.ex
defmodule MCPServer.Tools.FsLs do
  use MCPServer.Tool

  def name(), do: "fs_ls"
  def category(), do: :filesystem

  def description() do
    "Lists files and directories in the specified path"
  end

  def input_schema() do
    %{
      "type" => "object",
      "properties" => %{
        "path" => %{
          "type" => "string",
          "description" => "Directory path to list (defaults to current directory)",
          "default" => "."
        },
        "show_hidden" => %{
          "type" => "boolean",
          "description" => "Whether to show hidden files/directories",
          "default" => false
        },
        "recursive" => %{
          "type" => "boolean",
          "description" => "Whether to list files recursively",
          "default" => false
        }
      },
      "required" => []
    }
  end

  def handle(args) do
    path = Map.get(args, "path", ".")
    show_hidden = Map.get(args, "show_hidden", false)
    recursive = Map.get(args, "recursive", false)

    try do
      if File.exists?(path) and File.dir?(path) do
        files = list_files(path, show_hidden, recursive)
        {:ok, create_text_response(format_file_list(files, path))}
      else
        {:error, create_text_response("Directory does not exist: #{path}")}
      end
    rescue
      error ->
        {:error, create_text_response("Error listing directory: #{Exception.message(error)}")}
    end
  end

  defp list_files(path, show_hidden, recursive) do
    if recursive do
      list_files_recursive(path, show_hidden, [])
    else
      list_files_single(path, show_hidden)
    end
  end

  defp list_files_single(path, show_hidden) do
    path
    |> File.ls!()
    |> Enum.filter(fn file ->
      show_hidden or not String.starts_with?(file, ".")
    end)
    |> Enum.map(fn file ->
      file_path = Path.join(path, file)
      stat = File.stat!(file_path)

      %{
        name: file,
        path: file_path,
        type: if(stat.type == :directory, do: "directory", else: "file"),
        size: stat.size,
        modified: stat.mtime
      }
    end)
    |> Enum.sort_by(fn %{type: type, name: name} -> {type, name} end)
  end

  defp list_files_recursive(path, show_hidden, acc) do
    entries = list_files_single(path, show_hidden)

    directories = Enum.filter(entries, &(&1.type == "directory"))

    recursive_entries =
      Enum.flat_map(directories, fn dir ->
        list_files_recursive(dir.path, show_hidden, [])
      end)

    entries ++ recursive_entries
  end

  defp format_file_list(files, base_path) do
    header = "Listing for: #{base_path}\n#{String.duplicate("=", 50)}\n"

    if Enum.empty?(files) do
      header <> "Directory is empty"
    else
      file_lines =
        Enum.map(files, fn file ->
          type_indicator = if file.type == "directory", do: "📁", else: "📄"
          size_str = if file.type == "file", do: format_size(file.size), else: ""
          "#{type_indicator} #{file.name} #{size_str}"
        end)

      header <> Enum.join(file_lines, "\n")
    end
  end

  defp format_size(size) when size < 1024, do: "#{size}B"
  defp format_size(size) when size < 1024 * 1024, do: "#{Float.round(size / 1024, 1)}KB"

  defp format_size(size) when size < 1024 * 1024 * 1024,
    do: "#{Float.round(size / (1024 * 1024), 1)}MB"

  defp format_size(size), do: "#{Float.round(size / (1024 * 1024 * 1024), 1)}GB"

  defp create_text_response(text) do
    %{
      "content" => [
        %{
          "text" => text,
          "type" => "text"
        }
      ]
    }
  end
end

# File: lib/mcp_server/tools/fs_read.ex
defmodule MCPServer.Tools.FsRead do
  use MCPServer.Tool

  def name(), do: "fs_read"
  def category(), do: :filesystem

  def description() do
    "Reads content from one or more files"
  end

  def input_schema() do
    %{
      "type" => "object",
      "properties" => %{
        "files" => %{
          "type" => "array",
          "description" => "Array of file paths to read",
          "items" => %{"type" => "string"}
        },
        "encoding" => %{
          "type" => "string",
          "description" => "File encoding (utf8, binary, latin1)",
          "default" => "utf8"
        },
        "max_size" => %{
          "type" => "integer",
          "description" => "Maximum file size in bytes (0 = no limit)",
          "default" => 0
        }
      },
      "required" => ["files"]
    }
  end

  def handle(%{"files" => files} = args) do
    encoding = Map.get(args, "encoding", "utf8")
    max_size = Map.get(args, "max_size", 0)

    results =
      Enum.map(files, fn file_path ->
        read_single_file(file_path, encoding, max_size)
      end)

    format_results(results)
  end

  defp read_single_file(file_path, encoding, max_size) do
    try do
      unless File.exists?(file_path) do
        throw({:error, "File does not exist"})
      end

      unless File.regular?(file_path) do
        throw({:error, "Path is not a regular file"})
      end

      stat = File.stat!(file_path)

      if max_size > 0 and stat.size > max_size do
        throw({:error, "File size (#{stat.size}) exceeds maximum (#{max_size})"})
      end

      encoding_atom = encoding_to_atom(encoding)
      content = File.read!(file_path, [encoding_atom])

      {:ok, file_path, content, stat.size}
    rescue
      error ->
        {:error, file_path, Exception.message(error)}
    catch
      {:error, reason} ->
        {:error, file_path, reason}
    end
  end

  defp encoding_to_atom("utf8"), do: :utf8
  defp encoding_to_atom("binary"), do: :binary
  defp encoding_to_atom("latin1"), do: :latin1
  defp encoding_to_atom(_), do: :utf8

  defp format_results(results) do
    {success_count, error_count} =
      Enum.reduce(results, {0, 0}, fn
        {:ok, _, _, _}, {succ, err} -> {succ + 1, err}
        {:error, _, _}, {succ, err} -> {succ, err + 1}
      end)

    if length(results) == 1 do
      # Single file - return content directly or error
      case List.first(results) do
        {:ok, file_path, content, size} ->
          header = "File: #{file_path} (#{format_size(size)})\n#{String.duplicate("=", 50)}\n"
          {:ok, create_text_response(header <> content)}

        {:error, file_path, reason} ->
          {:error, create_text_response("Error reading #{file_path}: #{reason}")}
      end
    else
      # Multiple files - return formatted summary
      summary =
        "Read #{length(results)} files: #{success_count} successful, #{error_count} failed\n\n"

      details =
        Enum.map(results, fn
          {:ok, file_path, content, size} ->
            "✓ #{file_path} (#{format_size(size)}):\n#{String.duplicate("-", 30)}\n#{content}\n"

          {:error, file_path, reason} ->
            "✗ #{file_path}: #{reason}\n"
        end)

      full_text = summary <> Enum.join(details, "\n")
      {:ok, create_text_response(full_text)}
    end
  end

  defp format_size(size) when size < 1024, do: "#{size}B"
  defp format_size(size) when size < 1024 * 1024, do: "#{Float.round(size / 1024, 1)}KB"

  defp format_size(size) when size < 1024 * 1024 * 1024,
    do: "#{Float.round(size / (1024 * 1024), 1)}MB"

  defp format_size(size), do: "#{Float.round(size / (1024 * 1024 * 1024), 1)}GB"

  defp create_text_response(text) do
    %{
      "content" => [
        %{
          "text" => text,
          "type" => "text"
        }
      ]
    }
  end
end

# File: lib/mcp_server/tools/fs_write.ex
defmodule MCPServer.Tools.FsWrite do
  use MCPServer.Tool

  def name(), do: "fs_write"
  def category(), do: :filesystem

  def description() do
    "Writes content to one or more files"
  end

  def input_schema() do
    %{
      "type" => "object",
      "properties" => %{
        "files" => %{
          "type" => "array",
          "description" => "Array of file objects to write",
          "items" => %{
            "type" => "object",
            "properties" => %{
              "file_path" => %{
                "type" => "string",
                "description" => "Path where the file should be written"
              },
              "content" => %{
                "type" => "string",
                "description" => "Content to write to the file"
              },
              "encoding" => %{
                "type" => "string",
                "description" => "File encoding (utf8, binary, latin1)",
                "default" => "utf8"
              },
              "mode" => %{
                "type" => "string",
                "description" => "Write mode (write, append)",
                "default" => "write"
              }
            },
            "required" => ["file_path", "content"]
          }
        },
        "create_dirs" => %{
          "type" => "boolean",
          "description" => "Whether to create parent directories if they don't exist",
          "default" => true
        },
        "stop_on_error" => %{
          "type" => "boolean",
          "description" => "Whether to stop processing on first error",
          "default" => false
        }
      },
      "required" => ["files"]
    }
  end

  def handle(%{"files" => files} = args) do
    # Extract global options
    create_dirs = Map.get(args, "create_dirs", true)
    stop_on_error = Map.get(args, "stop_on_error", false)

    # Process each file
    {results, should_continue} =
      Enum.reduce_while(files, {[], true}, fn file, {acc_results, _} ->
        result = write_single_file(file, create_dirs)
        new_results = [result | acc_results]

        # Check if we should continue based on stop_on_error setting
        continue =
          if stop_on_error do
            case result do
              {:ok, _} -> true
              {:error, _} -> false
            end
          else
            true
          end

        if continue do
          {:cont, {new_results, true}}
        else
          {:halt, {new_results, false}}
        end
      end)

    # Reverse to maintain original order
    results = Enum.reverse(results)

    # Generate summary
    {success_count, error_count} =
      Enum.reduce(results, {0, 0}, fn
        {:ok, _}, {succ, err} -> {succ + 1, err}
        {:error, _}, {succ, err} -> {succ, err + 1}
      end)

    # Format detailed results
    details =
      Enum.map(results, fn
        {:ok, path} -> "✓ #{path}"
        {:error, {path, reason}} -> "✗ #{path}: #{reason}"
      end)

    summary =
      "Processed #{length(files)} files: #{success_count} successful, #{error_count} failed"

    summary =
      if not should_continue and stop_on_error do
        summary <> " (stopped early due to error)"
      else
        summary
      end

    full_text = [summary, "" | details] |> Enum.join("\n")

    {:ok, create_text_response(full_text)}
  end

  # Helper function to write a single file
  defp write_single_file(file, create_dirs) do
    file_path = Map.get(file, "file_path")
    content = Map.get(file, "content")
    encoding = Map.get(file, "encoding", "utf8")
    mode = Map.get(file, "mode", "write")

    try do
      # Create parent directories if requested
      if create_dirs do
        file_path
        |> Path.dirname()
        |> File.mkdir_p!()
      end

      # Write the file based on mode
      result =
        case mode do
          "append" ->
            File.write(file_path, content, [:append, encoding_to_atom(encoding)])

          _ ->
            File.write(file_path, content, [encoding_to_atom(encoding)])
        end

      case result do
        :ok -> {:ok, file_path}
        {:error, reason} -> {:error, {file_path, inspect(reason)}}
      end
    rescue
      error -> {:error, {file_path, Exception.message(error)}}
    end
  end

  defp encoding_to_atom("utf8"), do: :utf8
  defp encoding_to_atom("binary"), do: :binary
  defp encoding_to_atom("latin1"), do: :latin1
  defp encoding_to_atom(_), do: :utf8

  defp create_text_response(text) do
    %{
      "content" => [
        %{
          "text" => text,
          "type" => "text"
        }
      ]
    }
  end
end
