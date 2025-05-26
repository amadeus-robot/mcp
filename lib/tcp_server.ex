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
    spawn_link(fn -> accept_loop(listen_socket) end)

    {:ok, %{listen_socket: listen_socket, port: port}}
  end

  defp accept_loop(listen_socket) do
    case :gen_tcp.accept(listen_socket) do
      {:ok, client_socket} ->
        Logger.info("New client connected")

        # Spawn a process to handle this client
        spawn(fn -> __MODULE__.handle_client(client_socket) end)

        # Continue accepting new connections
        accept_loop(listen_socket)

      {:error, reason} ->
        Logger.error("Failed to accept connection: #{inspect(reason)}")
        accept_loop(listen_socket)
    end
  end

  def handle_client(socket, rest \\ "") do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        IO.inspect({:got, data})

        json_data = rest <> data

        case Jason.decode(json_data) do
          {:ok, request} ->
            response = __MODULE__.handle_jsonrpc_request(request)
            response_json = Jason.encode!(response) <> "\n"

            :gen_tcp.send(socket, response_json)

            # Continue handling requests from this client
            __MODULE__.handle_client(socket)

          {:error, error} ->
            __MODULE__.handle_client(socket, json_data)
        end

      {:error, :closed} ->
        Logger.info("Client disconnected")
        :gen_tcp.close(socket)

      {:error, reason} ->
        Logger.error("Error receiving data: #{inspect(reason)}")
        :gen_tcp.close(socket)
    end
  end

  def handle_jsonrpc_request(%{"jsonrpc" => "2.0", "method" => method, "id" => id} = request) do
    params = Map.get(request, "params", [])

    IO.inspect({:request, method, id, params})

    res =
      try do
        dispatch_method(method, params)
      catch
        a, b ->
          {:error, -32600, inspect({a, b})}
      end

    case res do
      {:ok, result} ->
        %{
          "jsonrpc" => "2.0",
          "result" => result,
          "id" => id
        }

      {:error, code, message} ->
        create_error_response(id, code, message)
    end
  end

  def handle_jsonrpc_request(%{"jsonrpc" => "2.0", "method" => method} = request) do
    # Notification (no id field) - don't send response
    IO.inspect({:notification, method, request["id"]})
    params = Map.get(request, "params", [])
    dispatch_method(method, params)
    nil
  end

  def handle_jsonrpc_request(%{"id" => id}) do
    create_error_response(id, -32600, "Invalid Request")
  end

  def handle_jsonrpc_request(_) do
    create_error_response(nil, -32600, "Invalid Request")
  end

  # Protocol version validation
  def validate_protocol_version("2024-11-05"), do: :ok
  # Also support older version
  def validate_protocol_version("2024-10-07"), do: :ok

  def validate_protocol_version(version) do
    {:error,
     "Unsupported protocol version: #{version}. Supported versions: 2024-11-05, 2024-10-07"}
  end

  def dispatch_method("initialize", params) do
    client_info = Map.get(params, "clientInfo", %{})
    protocol_version = Map.get(params, "protocolVersion", "2024-11-05")
    capabilities = Map.get(params, "capabilities", %{})

    Logger.info("MCP Initialize request from client: #{inspect(client_info)}")
    Logger.info("Protocol version: #{protocol_version}")
    Logger.info("Client capabilities: #{inspect(capabilities)}")

    # Validate protocol version
    case validate_protocol_version(protocol_version) do
      :ok ->
        result = %{
          "protocolVersion" => "2024-11-05",
          "capabilities" => %{"tools" => %{}},
          "serverInfo" => %{
            "name" => "elixir-mcp-server",
            "version" => "1.0.0"
          },
          "instructions" => "use this server to do elixir tasks"
        }

        {:ok, result}

      {:error, message} ->
        {:error, -32602, message}
    end
  end

  def dispatch_method("prompts/list", params) do
    {:ok, %{"prompts" => []}}
  end

  def dispatch_method("resources/list", params) do
    {:ok, %{"resources" => []}}
  end

  def dispatch_method("tools/list", params) do
    {:ok, MCPServer.Tools.get_tools_list()}
  end

  def dispatch_method("tools/call", params) do
    MCPServer.Tools.dispatch_tool_call(params)
  end

  def dispatch_method(method, _params) do
    {:error, -32601, "Method not found: #{method}"}
  end

  def create_error_response(id, code, message) do
    %{
      "jsonrpc" => "2.0",
      "error" => %{
        "code" => code,
        "message" => message
      },
      "id" => id
    }
  end

  def test() do
    MCPServer.Tools.test()
  end
end
