defmodule MCPServer.Toolsi do
  require Logger

  def get_tools_list() do
    %{
      "tools" => [
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
        }
      ]
    }
  end

  def dispatch_tool_call(%{"arguments" => args, "name" => tool_name}) do
    case tool_name do
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

  # Elixir Evaluation Tool

  def handle_eval_elixir_snippet(%{"code" => code}) do
    res = SafeEvaluator.eval(code)

    {:ok, create_text_response(inspect(res, pretty: true))}
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
