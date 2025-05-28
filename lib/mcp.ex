defmodule MCPServer do
  use Supervisor
  require Logger

  def start(type \\ :manual, args \\ []) do
    Logger.info("Starting MCPServer with type: #{inspect(type)}, args: #{inspect(args)}")

    # Start the main supervisor
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def start_link(args \\ []) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(args) do
    port = Keyword.get(args, :port, 5000)

    Logger.info("Initializing MCPServer on port #{port}")

    children = [
      # Start the tool registry first
      MCPServer.ToolRegistry,

      # Start the client supervisor
      MCPServer.ClientSupervisor,

      # Start the TCP server
      {MCPServer.TcpServer, port}
    ]

    # Use one_for_one strategy - if one child crashes, restart only that child
    opts = [strategy: :one_for_one, name: MCPServer.Supervisor]

    case Supervisor.init(children, opts) do
      {:ok, _} = result ->
        # Discover tools after supervisor is initialized
        spawn(fn ->
          # Give registry time to start
          :timer.sleep(100)
          ModuleLoader.load_namespace("MCPServer.Tools.")
          MCPServer.ToolRegistry.discover_tools()
          Logger.info("Tool discovery completed")
        end)

        result

      error ->
        Logger.error("Failed to initialize MCPServer: #{inspect(error)}")
        error
    end
  end

  # Convenience functions for external control
  def stop() do
    Supervisor.stop(__MODULE__)
  end

  def restart() do
    case stop() do
      :ok -> start_link()
      error -> error
    end
  end

  def get_server_info() do
    %{
      name: "elixir-mcp-server",
      version: "1.0.0",
      port: get_port(),
      status: get_status(),
      tools_count: MCPServer.ToolRegistry.count_tools()
    }
  end

  defp get_port() do
    case Process.whereis(MCPServer.TcpServer) do
      nil ->
        nil

      pid ->
        try do
          :sys.get_state(pid)
          |> Map.get(:port)
        catch
          _, _ -> nil
        end
    end
  end

  defp get_status() do
    case Process.whereis(__MODULE__) do
      nil -> :stopped
      _pid -> :running
    end
  end
end
