# lib/mcp_server/tcp_server.ex (Updated)
defmodule MCPServer.TcpServer do
  use GenServer
  require Logger

  def start_link(port) do
    GenServer.start_link(__MODULE__, port, name: __MODULE__)
  end

  @impl true
  def init(port) do
    {:ok, listen_socket} =
      :gen_tcp.listen(port, [
        :binary,
        packet: :line,
        active: false,
        reuseaddr: true
      ])

    Logger.info("JSON-RPC TCP server listening on port #{port}")

    # Start accepting connections
    send(self(), :accept)

    {:ok, %{listen_socket: listen_socket, port: port}}
  end

  @impl true
  def handle_info(:accept, %{listen_socket: listen_socket} = state) do
    case :gen_tcp.accept(listen_socket) do
      {:ok, client_socket} ->
        Logger.info("New client connected")

        # Start supervised client handler
        case MCPServer.ClientSupervisor.start_client(client_socket) do
          {:ok, client_pid} ->
            case :gen_tcp.controlling_process(client_socket, client_pid) do
              :ok ->
                Logger.info("Client handler started and socket ownership transferred")
                # Optionally notify the client handler that it now owns the socket
                GenServer.cast(client_pid, :socket_ready)

              {:error, reason} ->
                Logger.error("Failed to transfer socket ownership: #{inspect(reason)}")
                :gen_tcp.close(client_socket)
                # Terminate the client handler since socket transfer failed
                GenServer.stop(client_pid, :normal)
            end

          {:error, reason} ->
            Logger.error("Failed to start client handler: #{inspect(reason)}")
            :gen_tcp.close(client_socket)
        end

      {:error, reason} ->
        Logger.error("Failed to accept connection: #{inspect(reason)}")
    end

    # Continue accepting new connections
    send(self(), :accept)
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, %{listen_socket: listen_socket}) do
    :gen_tcp.close(listen_socket)
    :ok
  end

  def test() do
    MCPServer.Tools.test()
  end
end

# Add to your application supervisor tree (in application.ex)
# children = [
#   MCPServer.ClientSupervisor,
#   {MCPServer.TcpServer, 8080}
# ]
