defmodule MCPServer.Toolsi do
  require Logger

  def get_tools_list() do
    %{
      "tools" => [
        %{
          "name" => "eval_elixir_snippet",
          "description" => "runs an snippet of elixir code and returns the results",
          "inputSchema" => %{
            "properties" => %{"code" => %{"type" => "string"}},
            "required" => ["code"],
            "type" => "object"
          }
        },
        %{
          "name" => "fs_ls",
          "description" => "Lists files and directories in the specified path",
          "inputSchema" => %{
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
        },
        %{
          "name" => "fs_read",
          "description" => "Reads content from one or more files",
          "inputSchema" => %{
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
        },
        %{
          "name" => "hfm_create_layer",
          "description" =>
            "Creates a new layer with the specified parent layer, becoming the new head layer",
          "inputSchema" => %{
            "type" => "object",
            "properties" => %{
              "parent_layer_id" => %{
                "type" => "integer",
                "description" => "ID of the parent layer"
              }
            },
            "required" => ["parent_layer_id"]
          }
        },
        %{
          "name" => "hfm_store_module_declarations",
          "description" =>
            "Stores module-level declarations (use, require, import, alias) for a module",
          "inputSchema" => %{
            "type" => "object",
            "properties" => %{
              "module_name" => %{"type" => "string", "description" => "Name of the module"},
              "declarations" => %{
                "type" => "array",
                "description" =>
                  "List of declaration lines like ['use GenServer', 'alias Geom.Square as Sq']",
                "items" => "string"
              },
              "layer_id" => %{
                "type" => ["integer", "string"],
                "description" => "Layer ID or :head for current head",
                "default" => ":head"
              }
            },
            "required" => ["module_name", "declarations"]
          }
        },
        %{
          "name" => "hfm_get_module_declarations",
          "description" =>
            "Retrieves module declarations from the specified layer, walking up the hierarchy if needed",
          "inputSchema" => %{
            "type" => "object",
            "properties" => %{
              "module_name" => %{"type" => "string", "description" => "Name of the module"},
              "layer_id" => %{
                "type" => ["integer", "string"],
                "description" => "Layer ID or :head for current head",
                "default" => ":head"
              }
            },
            "required" => ["module_name"]
          }
        },
        %{
          "name" => "hfm_store_function",
          "description" => "Stores a function in the specified layer",
          "inputSchema" => %{
            "type" => "object",
            "properties" => %{
              "module_name" => %{"type" => "string", "description" => "Name of the module"},
              "function_name" => %{"type" => "string", "description" => "Name of the function"},
              "code" => %{"type" => "string", "description" => "Function code"},
              "layer_id" => %{
                "type" => ["integer", "string"],
                "description" => "Layer ID or :head for current head",
                "default" => ":head"
              }
            },
            "required" => ["module_name", "function_name", "code"]
          }
        },
        %{
          "name" => "hfm_get_function",
          "description" =>
            "Retrieves a function from the specified layer, walking up the hierarchy if needed",
          "inputSchema" => %{
            "type" => "object",
            "properties" => %{
              "module_name" => %{"type" => "string", "description" => "Name of the module"},
              "function_name" => %{"type" => "string", "description" => "Name of the function"},
              "layer_id" => %{
                "type" => ["integer", "string"],
                "description" => "Layer ID or :head for current head",
                "default" => ":head"
              }
            },
            "required" => ["module_name", "function_name"]
          }
        },
        %{
          "name" => "hfm_render_module",
          "description" =>
            "Renders a complete module by collecting all functions and declarations for the specified module",
          "inputSchema" => %{
            "type" => "object",
            "properties" => %{
              "module_name" => %{
                "type" => "string",
                "description" => "Name of the module to render"
              },
              "layer_id" => %{
                "type" => ["integer", "string"],
                "description" => "Layer ID or :head for current head",
                "default" => ":head"
              }
            },
            "required" => ["module_name"]
          }
        },
        %{
          "name" => "hfm_render_all_modules",
          "description" => "Renders all modules visible from the specified layer",
          "inputSchema" => %{
            "type" => "object",
            "properties" => %{
              "layer_id" => %{
                "type" => ["integer", "string"],
                "description" => "Layer ID or :head for current head",
                "default" => ":head"
              }
            },
            "required" => []
          }
        },
        %{
          "name" => "hfm_list_functions",
          "description" => "Lists all functions visible from the specified layer",
          "inputSchema" => %{
            "type" => "object",
            "properties" => %{
              "layer_id" => %{
                "type" => ["integer", "string"],
                "description" => "Layer ID or :head for current head",
                "default" => ":head"
              }
            },
            "required" => []
          }
        },
        %{
          "name" => "hfm_list_module_declarations",
          "description" => "Lists all module declarations visible from the specified layer",
          "inputSchema" => %{
            "type" => "object",
            "properties" => %{
              "layer_id" => %{
                "type" => ["integer", "string"],
                "description" => "Layer ID or :head for current head",
                "default" => ":head"
              }
            },
            "required" => []
          }
        },
        %{
          "name" => "hfm_get_layer_chain",
          "description" => "Gets the complete inheritance chain for a layer",
          "inputSchema" => %{
            "type" => "object",
            "properties" => %{
              "layer_id" => %{
                "type" => ["integer", "string"],
                "description" => "Layer ID or :head for current head",
                "default" => ":head"
              }
            },
            "required" => []
          }
        },
        %{
          "name" => "hfm_get_head_layer",
          "description" => "Gets the current head layer ID",
          "inputSchema" => %{
            "type" => "object",
            "properties" => %{},
            "required" => []
          }
        },
        %{
          "name" => "hfm_list_layers",
          "description" => "Lists all layer IDs in order from head to root",
          "inputSchema" => %{
            "type" => "object",
            "properties" => %{},
            "required" => []
          }
        },
        %{
          "name" => "hfm_delete_function",
          "description" =>
            "Deletes a function from the specified layer (creates a tombstone that masks the function in parent layers)",
          "inputSchema" => %{
            "type" => "object",
            "properties" => %{
              "module_name" => %{"type" => "string", "description" => "Name of the module"},
              "function_name" => %{"type" => "string", "description" => "Name of the function"},
              "layer_id" => %{
                "type" => ["integer", "string"],
                "description" => "Layer ID or :head for current head",
                "default" => ":head"
              }
            },
            "required" => ["module_name", "function_name"]
          }
        },
        %{
          "name" => "hfm_delete_module_declarations",
          "description" =>
            "Deletes module declarations from the specified layer (creates a tombstone that masks the declarations in parent layers)",
          "inputSchema" => %{
            "type" => "object",
            "properties" => %{
              "module_name" => %{"type" => "string", "description" => "Name of the module"},
              "layer_id" => %{
                "type" => ["integer", "string"],
                "description" => "Layer ID or :head for current head",
                "default" => ":head"
              }
            },
            "required" => ["module_name"]
          }
        },
        %{
          "name" => "hfm_get_stats",
          "description" => "Gets statistics about the function storage system",
          "inputSchema" => %{
            "type" => "object",
            "properties" => %{},
            "required" => []
          }
        },
        %{
          "name" => "hfm_compact_layer",
          "description" =>
            "Compacts a layer by removing functions that are identical to their parent layer",
          "inputSchema" => %{
            "type" => "object",
            "properties" => %{
              "layer_id" => %{
                "type" => ["integer", "string"],
                "description" => "Layer ID or :head for current head",
                "default" => ":head"
              }
            },
            "required" => []
          }
        },
        %{
          "name" => "hfm_save_to_disk",
          "description" => "Saves all layers to disk using ETS tab2file",
          "inputSchema" => %{
            "type" => "object",
            "properties" => %{
              "base_path" => %{
                "type" => "string",
                "description" => "Base path for saving layers",
                "default" => "./layers"
              }
            },
            "required" => []
          }
        },
        %{
          "name" => "hfm_load_from_disk",
          "description" =>
            "Loads all layers from disk using ETS file2tab (replaces current state)",
          "inputSchema" => %{
            "type" => "object",
            "properties" => %{
              "base_path" => %{
                "type" => "string",
                "description" => "Base path for loading layers",
                "default" => "./layers"
              }
            },
            "required" => []
          }
        },
        %{
          "name" => "write_files",
          "description" => "Writes content to multiple files in a single operation",
          "inputSchema" => %{
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
                      "description" => "File encoding (utf8, binary, etc.)",
                      "default" => "utf8"
                    },
                    "mode" => %{
                      "type" => "string",
                      "description" => "Write mode: 'write' (overwrite) or 'append'",
                      "default" => "write"
                    }
                  },
                  "required" => ["file_path", "content"]
                }
              },
              "create_dirs" => %{
                "type" => "boolean",
                "description" =>
                  "Whether to create parent directories if they don't exist (applies to all files)",
                "default" => true
              },
              "stop_on_error" => %{
                "type" => "boolean",
                "description" => "Whether to stop processing if any file fails to write",
                "default" => false
              }
            },
            "required" => ["files"]
          }
        }
      ]
    }
  end

  def dispatch_tool_call(%{"arguments" => args, "name" => tool_name}) do
    case tool_name do
      "eval_elixir_snippet" -> handle_eval_elixir_snippet(args)
      "fs_ls" -> handle_fs_ls(args)
      "fs_read" -> handle_fs_read(args)
      "fs_write_files" -> handle_write_files(args)
      "hfm_create_layer" -> handle_hfm_create_layer(args)
      "hfm_store_module_declarations" -> handle_hfm_store_module_declarations(args)
      "hfm_get_module_declarations" -> handle_hfm_get_module_declarations(args)
      "hfm_store_function" -> handle_hfm_store_function(args)
      "hfm_get_function" -> handle_hfm_get_function(args)
      "hfm_render_module" -> handle_hfm_render_module(args)
      "hfm_render_all_modules" -> handle_hfm_render_all_modules(args)
      "hfm_list_functions" -> handle_hfm_list_functions(args)
      "hfm_list_module_declarations" -> handle_hfm_list_module_declarations(args)
      "hfm_get_layer_chain" -> handle_hfm_get_layer_chain(args)
      "hfm_get_head_layer" -> handle_hfm_get_head_layer(args)
      "hfm_list_layers" -> handle_hfm_list_layers(args)
      "hfm_delete_function" -> handle_hfm_delete_function(args)
      "hfm_delete_module_declarations" -> handle_hfm_delete_module_declarations(args)
      "hfm_get_stats" -> handle_hfm_get_stats(args)
      "hfm_compact_layer" -> handle_hfm_compact_layer(args)
      "hfm_save_to_disk" -> handle_hfm_save_to_disk(args)
      "hfm_load_from_disk" -> handle_hfm_load_from_disk(args)
      _ -> {:error, -32601, "Tool not found: #{tool_name}"}
    end
  end

  # Filesystem Tools

  def handle_fs_ls(args) do
    path = Map.get(args, "path", ".")
    show_hidden = Map.get(args, "show_hidden", false)
    recursive = Map.get(args, "recursive", false)

    try do
      case File.stat(path) do
        {:ok, %{type: :directory}} ->
          files =
            if recursive do
              list_files_recursive(path, show_hidden)
            else
              list_files_single(path, show_hidden)
            end

          files_text = format_file_list(files, recursive)
          {:ok, create_text_response("Directory listing for #{path}:\n#{files_text}")}

        {:ok, %{type: :regular}} ->
          {:ok, create_text_response("#{path} is a file, not a directory")}

        {:error, reason} ->
          {:ok, create_text_response("Error accessing #{path}: #{inspect(reason)}")}
      end
    rescue
      error ->
        {:ok, create_text_response("Error listing directory: #{Exception.message(error)}")}
    end
  end

  defp list_files_single(path, show_hidden) do
    case File.ls(path) do
      {:ok, files} ->
        files
        |> Enum.filter(fn file -> show_hidden || !String.starts_with?(file, ".") end)
        |> Enum.map(fn file ->
          full_path = Path.join(path, file)

          case File.stat(full_path) do
            {:ok, stat} -> {file, stat.type, stat.size}
            {:error, _} -> {file, :unknown, 0}
          end
        end)
        |> Enum.sort()

      {:error, reason} ->
        []
    end
  end

  defp list_files_recursive(path, show_hidden) do
    try do
      path
      |> File.ls!()
      |> Enum.filter(fn file -> show_hidden || !String.starts_with?(file, ".") end)
      |> Enum.flat_map(fn file ->
        full_path = Path.join(path, file)
        relative_path = Path.relative_to(full_path, ".")

        case File.stat(full_path) do
          {:ok, %{type: :directory}} ->
            [{relative_path, :directory, 0} | list_files_recursive(full_path, show_hidden)]

          {:ok, stat} ->
            [{relative_path, stat.type, stat.size}]

          {:error, _} ->
            [{relative_path, :unknown, 0}]
        end
      end)
    rescue
      _ -> []
    end
  end

  defp format_file_list(files, recursive) do
    if Enum.empty?(files) do
      "(empty directory)"
    else
      files
      |> Enum.map(fn {name, type, size} ->
        type_indicator =
          case type do
            :directory -> "d"
            :regular -> "f"
            :symlink -> "l"
            _ -> "?"
          end

        size_str = if type == :directory, do: "", else: " (#{format_size(size)})"
        "#{type_indicator} #{name}#{size_str}"
      end)
      |> Enum.join("\n")
    end
  end

  defp format_size(size) when size < 1024, do: "#{size}B"
  defp format_size(size) when size < 1024 * 1024, do: "#{Float.round(size / 1024, 1)}KB"

  defp format_size(size) when size < 1024 * 1024 * 1024,
    do: "#{Float.round(size / (1024 * 1024), 1)}MB"

  defp format_size(size), do: "#{Float.round(size / (1024 * 1024 * 1024), 1)}GB"

  def handle_fs_read(args) do
    %{"files" => file_paths} = args
    encoding = Map.get(args, "encoding", "utf8") |> encoding_to_atom()
    max_size = Map.get(args, "max_size", 0)

    results =
      Enum.map(file_paths, fn file_path ->
        read_single_file(file_path, encoding, max_size)
      end)

    # Format results
    formatted_results =
      results
      |> Enum.map(fn
        {:ok, file_path, content} ->
          "=== #{file_path} ===\n#{content}"

        {:error, file_path, reason} ->
          "=== #{file_path} (ERROR) ===\nError: #{reason}"
      end)
      |> Enum.join("\n\n")

    # Generate summary
    {success_count, error_count} =
      Enum.reduce(results, {0, 0}, fn
        {:ok, _, _}, {succ, err} -> {succ + 1, err}
        {:error, _, _}, {succ, err} -> {succ, err + 1}
      end)

    summary =
      "Read #{length(file_paths)} files: #{success_count} successful, #{error_count} failed"

    full_text =
      if Enum.empty?(formatted_results) do
        summary
      else
        "#{summary}\n\n#{formatted_results}"
      end

    {:ok, create_text_response(full_text)}
  end

  defp read_single_file(file_path, encoding, max_size) do
    try do
      case File.stat(file_path) do
        {:ok, %{type: :regular, size: size}} ->
          if max_size > 0 && size > max_size do
            {:error, file_path, "File too large (#{size} bytes > #{max_size} bytes)"}
          else
            case File.read(file_path) do
              {:ok, content} ->
                # Convert encoding if needed
                final_content =
                  case encoding do
                    :utf8 ->
                      case :unicode.characters_to_binary(content, :utf8) do
                        utf8_content when is_binary(utf8_content) -> utf8_content
                        {:error, _, _} -> "(binary content - not valid UTF-8)"
                        {:incomplete, _, _} -> "(binary content - incomplete UTF-8)"
                      end

                    _ ->
                      content
                  end

                {:ok, file_path, final_content}

              {:error, reason} ->
                {:error, file_path, inspect(reason)}
            end
          end

        {:ok, %{type: type}} ->
          {:error, file_path, "Not a regular file (type: #{type})"}

        {:error, reason} ->
          {:error, file_path, inspect(reason)}
      end
    rescue
      error ->
        {:error, file_path, Exception.message(error)}
    end
  end

  # Elixir Evaluation Tool

  def handle_eval_elixir_snippet(%{"code" => code}) do
    res = SafeEvaluator.eval(code)

    {:ok, create_text_response(inspect(res, pretty: true))}
  end

  # File Writing Tool

  def handle_write_files(%{"files" => files} = args) do
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

  # HFM Tools

  def handle_hfm_create_layer(%{"parent_layer_id" => parent_layer_id}) do
    case HierarchicalFunctionManager.create_layer(HierarchicalFunctionManager, parent_layer_id) do
      {:ok, layer_id} ->
        {:ok,
         create_text_response("Created new layer #{layer_id} with parent #{parent_layer_id}")}

      {:error, reason} ->
        {:ok, create_text_response("Error creating layer: #{inspect(reason)}")}
    end
  end

  def handle_hfm_store_module_declarations(
        %{"module_name" => module_name, "declarations" => declarations} = args
      ) do
    metadata = Map.get(args, "metadata", %{})
    layer_id = Map.get(args, "layer_id", :head)

    case HierarchicalFunctionManager.store_module_declarations(
           HierarchicalFunctionManager,
           module_name,
           declarations,
           metadata,
           layer_id
         ) do
      {:ok, identifiers} ->
        {:ok,
         create_text_response(
           "Stored module declarations for #{module_name}: #{inspect(identifiers)}"
         )}

      {:error, reason} ->
        {:ok, create_text_response("Error storing module declarations: #{inspect(reason)}")}
    end
  end

  def handle_hfm_get_module_declarations(%{"module_name" => module_name} = args) do
    layer_id = Map.get(args, "layer_id", :head)

    case HierarchicalFunctionManager.get_module_declarations(
           HierarchicalFunctionManager,
           module_name,
           layer_id
         ) do
      {:ok, {declarations, metadata, found_layer_id}} ->
        {:ok,
         create_text_response(
           "Module declarations for #{module_name} (found in layer #{found_layer_id}):\nDeclarations: #{inspect(declarations, pretty: true)}\nMetadata: #{inspect(metadata, pretty: true)}"
         )}

      {:error, :not_found} ->
        {:ok, create_text_response("Module declarations not found for #{module_name}")}
    end
  end

  def handle_hfm_store_function(
        %{"module_name" => module_name, "function_name" => function_name, "code" => code} = args
      ) do
    metadata = Map.get(args, "metadata", %{})
    layer_id = Map.get(args, "layer_id", :head)

    case HierarchicalFunctionManager.store_function(
           HierarchicalFunctionManager,
           module_name,
           function_name,
           code,
           metadata,
           layer_id
         ) do
      {:ok, function_names} ->
        {:ok,
         create_text_response(
           "Stored function #{module_name}.#{function_name}: #{inspect(function_names)}"
         )}

      {:error, reason} ->
        {:ok, create_text_response("Error storing function: #{inspect(reason)}")}
    end
  end

  def handle_hfm_get_function(
        %{"module_name" => module_name, "function_name" => function_name} = args
      ) do
    layer_id = Map.get(args, "layer_id", :head)

    case HierarchicalFunctionManager.get_function(
           HierarchicalFunctionManager,
           module_name,
           function_name,
           layer_id
         ) do
      {:ok, {code, metadata, found_layer_id}} ->
        {:ok,
         create_text_response(
           "Function #{module_name}.#{function_name} (found in layer #{found_layer_id}):\n#{code}\n\nMetadata: #{inspect(metadata, pretty: true)}"
         )}

      {:error, :not_found} ->
        {:ok, create_text_response("Function #{module_name}.#{function_name} not found")}
    end
  end

  def handle_hfm_render_module(%{"module_name" => module_name} = args) do
    layer_id = Map.get(args, "layer_id", :head)

    case HierarchicalFunctionManager.render_module(
           HierarchicalFunctionManager,
           module_name,
           layer_id
         ) do
      {:ok, module_code} ->
        {:ok, create_text_response("Rendered module #{module_name}:\n\n#{module_code}")}

      {:error, reason} ->
        {:ok, create_text_response("Error rendering module: #{inspect(reason)}")}
    end
  end

  def handle_hfm_render_all_modules(args) do
    layer_id = Map.get(args, "layer_id", :head)

    case HierarchicalFunctionManager.render_all_modules(HierarchicalFunctionManager, layer_id) do
      {:ok, modules} ->
        rendered =
          modules
          |> Enum.map(fn {module_name, module_code} ->
            "=== #{module_name} ===\n#{module_code}"
          end)
          |> Enum.join("\n\n")

        {:ok, create_text_response("Rendered #{map_size(modules)} modules:\n\n#{rendered}")}

      {:error, reason} ->
        {:ok, create_text_response("Error rendering modules: #{inspect(reason)}")}
    end
  end

  def handle_hfm_list_functions(args) do
    layer_id = Map.get(args, "layer_id", :head)

    functions = HierarchicalFunctionManager.list_functions(HierarchicalFunctionManager, layer_id)

    {:ok,
     create_text_response(
       "Functions visible from layer #{layer_id}:\n#{inspect(functions, pretty: true)}"
     )}
  end

  def handle_hfm_list_module_declarations(args) do
    layer_id = Map.get(args, "layer_id", :head)

    declarations =
      HierarchicalFunctionManager.list_module_declarations(HierarchicalFunctionManager, layer_id)

    {:ok,
     create_text_response(
       "Module declarations visible from layer #{layer_id}:\n#{inspect(declarations, pretty: true)}"
     )}
  end

  def handle_hfm_get_layer_chain(args) do
    layer_id = Map.get(args, "layer_id", :head)

    chain = HierarchicalFunctionManager.get_layer_chain(HierarchicalFunctionManager, layer_id)

    {:ok, create_text_response("Layer chain from #{layer_id}: #{inspect(chain)}")}
  end

  def handle_hfm_get_head_layer(_args) do
    head_layer = HierarchicalFunctionManager.get_head_layer(HierarchicalFunctionManager)

    {:ok, create_text_response("Current head layer: #{inspect(head_layer)}")}
  end

  def handle_hfm_list_layers(_args) do
    layers = HierarchicalFunctionManager.list_layers(HierarchicalFunctionManager)

    {:ok, create_text_response("All layers (head to root): #{inspect(layers)}")}
  end

  def handle_hfm_delete_function(
        %{"module_name" => module_name, "function_name" => function_name} = args
      ) do
    layer_id = Map.get(args, "layer_id", :head)

    case HierarchicalFunctionManager.delete_function(
           HierarchicalFunctionManager,
           module_name,
           function_name,
           layer_id
         ) do
      :ok ->
        {:ok,
         create_text_response(
           "Deleted function #{module_name}.#{function_name} from layer #{layer_id}"
         )}

      {:error, reason} ->
        {:ok, create_text_response("Error deleting function: #{inspect(reason)}")}
    end
  end

  def handle_hfm_delete_module_declarations(%{"module_name" => module_name} = args) do
    layer_id = Map.get(args, "layer_id", :head)

    case HierarchicalFunctionManager.delete_module_declarations(
           HierarchicalFunctionManager,
           module_name,
           layer_id
         ) do
      :ok ->
        {:ok,
         create_text_response(
           "Deleted module declarations for #{module_name} from layer #{layer_id}"
         )}

      {:error, reason} ->
        {:ok, create_text_response("Error deleting module declarations: #{inspect(reason)}")}
    end
  end

  def handle_hfm_get_stats(_args) do
    stats = HierarchicalFunctionManager.get_stats(HierarchicalFunctionManager)

    {:ok, create_text_response("HFM Statistics:\n#{inspect(stats, pretty: true)}")}
  end

  def handle_hfm_compact_layer(args) do
    layer_id = Map.get(args, "layer_id", :head)

    case HierarchicalFunctionManager.compact_layer(layer_id) do
      {:ok, compacted_count} ->
        {:ok,
         create_text_response(
           "Compacted layer #{layer_id}, removed #{compacted_count} redundant functions"
         )}

      {:error, reason} ->
        {:ok, create_text_response("Error compacting layer: #{inspect(reason)}")}
    end
  end

  def handle_hfm_save_to_disk(args) do
    base_path = Map.get(args, "base_path", "./layers")

    case HierarchicalFunctionManager.save_to_disk(base_path) do
      :ok ->
        {:ok, create_text_response("Successfully saved all layers to #{base_path}")}

      {:error, reason} ->
        {:ok, create_text_response("Error saving to disk: #{inspect(reason)}")}
    end
  end

  def handle_hfm_load_from_disk(args) do
    base_path = Map.get(args, "base_path", "./layers")

    case HierarchicalFunctionManager.load_from_disk(base_path) do
      :ok ->
        {:ok, create_text_response("Successfully loaded all layers from #{base_path}")}

      {:error, reason} ->
        {:ok, create_text_response("Error loading from disk: #{inspect(reason)}")}
    end
  end

  # Helper Functions

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

  # Helper function to convert encoding string to atom
  defp encoding_to_atom("utf8"), do: :utf8
  defp encoding_to_atom("binary"), do: :raw
  defp encoding_to_atom("latin1"), do: :latin1
  defp encoding_to_atom(_), do: :utf8

  # Test function
  def test() do
    module_name = "Module1"
    declarations = [%{"name" => "value"}]

    {:ok, res} =
      handle_hfm_store_module_declarations(%{
        "module_name" => module_name,
        "declarations" => declarations
      })

    %{
      "content" => [
        %{
          "text" => "Stored module declarations for Module1: [\"Module1.__declarations__\"]",
          "type" => "text"
        }
      ]
    } = res

    function = "f1"
    code = "def my_code do 1 end"

    {:ok, res} =
      handle_hfm_store_function(%{
        "module_name" => module_name,
        "function_name" => function,
        "code" => code
      })

    %{
      "content" => [
        %{
          "text" => "Stored function Module1.f1: [\"Module1.f1\"]",
          "type" => "text"
        }
      ]
    } = res

    args = %{
      "declarations" => [
        "use Ecto.Schema",
        "import Ecto.Changeset",
        "alias MyApp.Repo as Repo"
      ],
      "module_name" => "MyApp.User"
    }

    {:ok, res} = handle_hfm_store_module_declarations(args)

    args = %{}

    {:ok, res} = handle_hfm_list_module_declarations(args)

    args = %{
      "module_name" => "MyApp.User"
    }

    {:ok, res} = handle_hfm_render_module(args)
  end
end
