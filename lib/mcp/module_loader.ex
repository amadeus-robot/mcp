defmodule ModuleLoader do
  @doc """
  Loads all modules under a given namespace prefix.

  Examples:
      ModuleLoader.load_namespace("MCPTools")
      ModuleLoader.load_namespace("MyApp.Services")
  """
  def load_namespace(namespace_prefix) when is_binary(namespace_prefix) do
    namespace_prefix
    |> find_modules_by_prefix()
    |> Enum.map(&load_module/1)
    |> Enum.filter(& &1)
  end

  @doc """
  Same as load_namespace/1 but accepts an atom
  """
  def load_namespace(namespace_prefix) when is_atom(namespace_prefix) do
    namespace_prefix
    |> Atom.to_string()
    |> load_namespace()
  end

  # Find all modules that match the namespace prefix
  def find_modules_by_prefix(prefix) do
    :code.all_available()
    |> Enum.map(fn {module_charlist, _path, _loaded} ->
      module_charlist |> List.to_string() |> String.to_atom()
    end)
    |> Enum.filter(&module_matches_prefix?(&1, prefix))
  end

  # Check if module name starts with the given prefix
  defp module_matches_prefix?(module, prefix) when is_atom(module) do
    module_string = Atom.to_string(module)

    # Handle both "Elixir.MCPTools" and "MCPTools" formats
    normalized_module = String.replace_prefix(module_string, "Elixir.", "")
    String.starts_with?(normalized_module, prefix)
  end

  # Attempt to load a single module
  defp load_module(module) do
    case Code.ensure_loaded(module) do
      {:module, ^module} ->
        IO.puts("✓ Loaded: #{module}")
        module

      {:error, reason} ->
        IO.puts("✗ Failed to load #{module}: #{reason}")
        nil
    end
  end
end
