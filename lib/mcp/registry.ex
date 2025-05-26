defmodule MCPServer.ToolRegistry do
  use GenServer
  require Logger

  @table_name :tool_registry

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    :ets.new(@table_name, [:set, :public, :named_table])
    {:ok, %{}}
  end

  @doc "Register a tool module"
  def register_tool(tool_module) when is_atom(tool_module) do
    if function_exported?(tool_module, :name, 0) do
      tool_name = tool_module.name()
      :ets.insert(@table_name, {tool_name, tool_module})
      Logger.info("Registered tool: #{tool_name}")
      :ok
    else
      {:error, "Module #{tool_module} does not implement Tool behavior"}
    end
  end

  @doc "Unregister a tool"
  def unregister_tool(tool_name) when is_binary(tool_name) do
    :ets.delete(@table_name, tool_name)
    Logger.info("Unregistered tool: #{tool_name}")
    :ok
  end

  @doc "Get all registered tools"
  def list_tools() do
    :ets.tab2list(@table_name)
    |> Enum.map(fn {name, module} -> {name, module} end)
    |> Enum.filter(fn {_name, module} ->
      apply(module, :enabled?, [])
    end)
  end

  @doc "Get tools by category"
  def list_tools_by_category(category) do
    list_tools()
    |> Enum.filter(fn {_name, module} ->
      apply(module, :category, []) == category
    end)
  end

  @doc "Find a tool module by name"
  def find_tool(tool_name) do
    case :ets.lookup(@table_name, tool_name) do
      [{^tool_name, module}] -> {:ok, module}
      [] -> {:error, :not_found}
    end
  end

  @doc "Auto-discover and register tools from modules"
  def discover_tools(module_prefix \\ MCPServer.Tools) do
    :code.all_loaded()
    |> Enum.map(fn {module, _} -> module end)
    |> Enum.filter(&tool_module?/1)
    |> Enum.filter(&String.starts_with?(Atom.to_string(&1), Atom.to_string(module_prefix)))
    |> Enum.each(&register_tool/1)
  end

  defp tool_module?(module) do
    try do
      module.module_info(:attributes)
      |> Keyword.get(:behaviour, [])
      |> Enum.member?(MCPServer.Tool)
    rescue
      _ -> false
    end
  end
end
