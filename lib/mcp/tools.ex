defmodule MCPServer.Tools do
  require Logger

  def start_link() do
    MCPServer.ToolRegistry.start_link()
    MCPServer.ToolRegistry.discover_tools()
  end

  @doc "Get the tool catalog for JSON-RPC"
  def get_tools_list() do
    tools =
      MCPServer.ToolRegistry.list_tools()
      |> Enum.map(fn {_name, module} ->
        %{
          "name" => apply(module, :name, []),
          "description" => apply(module, :description, []),
          "inputSchema" => apply(module, :input_schema, [])
        }
      end)

    %{"tools" => tools}
  end

  @doc "Dispatch a tool call to the appropriate handler"
  def dispatch_tool_call(%{"arguments" => args, "name" => tool_name}) do
    case MCPServer.ToolRegistry.find_tool(tool_name) do
      {:ok, module} ->
        try do
          module.handle(args)
        rescue
          error ->
            Logger.error("Error executing tool #{tool_name}: #{Exception.message(error)}")
            {:error, -32603, "Tool execution error: #{Exception.message(error)}"}
        end

      {:error, :not_found} ->
        {:error, -32601, "Tool not found: #{tool_name}"}
    end
  end

  @doc "Register a new tool at runtime"
  def register_tool(tool_module) do
    MCPServer.ToolRegistry.register_tool(tool_module)
  end

  @doc "Unregister a tool at runtime"
  def unregister_tool(tool_name) do
    MCPServer.ToolRegistry.unregister_tool(tool_name)
  end

  @doc "Get tools by category"
  def get_tools_by_category(category) do
    MCPServer.ToolRegistry.list_tools_by_category(category)
  end

  @doc "Initialize with default tools"
  def init_default_tools() do
    [
      MCPServer.Tools.Elixir,
      MCPServer.Tools.FileSystem,
      MCPServer.Tools.HFM
    ]
    |> Enum.each(&register_tool/1)

    # Auto-discover additional tools
    MCPServer.ToolRegistry.discover_tools()
  end
end
