# lib/mcp_server/client_handler.ex
defmodule MCPServer.ClientHandler do
  use GenServer
  require Logger

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket)
  end

  @impl true
  def init(socket) do
    Logger.info("Client handler started for socket #{inspect(socket)}")

    {:ok,
     %{
       socket: socket,
       buffer: "",
       ready: false
     }}
  end

  @impl true
  def handle_cast(:socket_ready, %{socket: socket} = state) do
    # Now we own the socket, we can set it to active mode
    :inet.setopts(socket, active: true)
    Logger.info("Socket ready for client handler")
    {:noreply, %{state | ready: true}}
  end

  @impl true
  def handle_cast({:notification, noti}, %{socket: socket} = state) do
    data = JSX.encode!(noti) <> "\n"
    :gen_tcp.send(socket, data)
 
    {:noreply, state}
  end

  @impl true
  def handle_info({:tcp, socket, data}, %{socket: socket, buffer: buffer} = state) do
    Logger.info("Received data: #{inspect(data)}")

    # Accumulate data in buffer
    new_buffer = buffer <> data

    # Process complete JSON messages
    {remaining_buffer, responses} = process_messages(new_buffer, [])

    # Send all responses
    Enum.each(responses, fn response ->
      if response do
        response_json = JSX.encode!(response) <> "\n"
        :gen_tcp.send(socket, response_json)
      end
    end)

    {:noreply, %{state | buffer: remaining_buffer}}
  end

  @impl true
  def handle_info({:tcp_closed, socket}, %{socket: socket} = state) do
    Logger.info("Client disconnected")
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:tcp_error, socket, reason}, %{socket: socket} = state) do
    Logger.error("TCP error: #{inspect(reason)}")
    {:stop, :normal, state}
  end

  @impl true
  def terminate(_reason, %{socket: socket}) do
    :gen_tcp.close(socket)
    :ok
  end

  # Process accumulated buffer data to extract complete JSON messages
  defp process_messages(buffer, responses) do
    case String.split(buffer, "\n", parts: 2) do
      [complete_line, rest] when complete_line != "" ->
        case JSX.decode(complete_line) do
          {:ok, request} ->
            response = handle_jsonrpc_request(request)
            process_messages(rest, [response | responses])

          {:error, _error} ->
            Logger.warning("Failed to decode JSON: #{inspect(complete_line)}")
            process_messages(rest, responses)
        end

      [incomplete] ->
        # No complete line yet, keep in buffer
        {incomplete, Enum.reverse(responses)}

      [] ->
        {"", Enum.reverse(responses)}
    end
  end

  defp handle_jsonrpc_request(%{"jsonrpc" => "2.0", "method" => method, "id" => id} = request) do
    params = Map.get(request, "params", [])
    Logger.debug("Processing request: #{method} with id: #{id}")

    result =
      try do
        dispatch_method(method, params)
      catch
        error_type, error ->
          Logger.error("Error processing method #{method}: #{inspect({error_type, error})}")
          {:error, -32603, "Internal error: #{inspect({error_type, error})}"}
      end

    case result do
      {:ok, response_data} ->
        %{
          "jsonrpc" => "2.0",
          "result" => response_data,
          "id" => id
        }

      {:error, code, message} ->
        create_error_response(id, code, message)
    end
  end

  defp handle_jsonrpc_request(%{"jsonrpc" => "2.0", "method" => method} = request) do
    # Notification (no id field) - don't send response
    params = Map.get(request, "params", [])
    Logger.debug("Processing notification: #{method}")

    try do
      dispatch_method(method, params)
    catch
      error_type, error ->
        Logger.error("Error processing notification #{method}: #{inspect({error_type, error})}")
    end

    nil
  end

  defp handle_jsonrpc_request(%{"id" => id}) do
    create_error_response(id, -32600, "Invalid Request")
  end

  defp handle_jsonrpc_request(_) do
    create_error_response(nil, -32600, "Invalid Request")
  end

  # Protocol version validation
  defp validate_protocol_version("2024-11-05"), do: :ok
  defp validate_protocol_version("2024-10-07"), do: :ok

  defp validate_protocol_version(version) do
    {:error,
     "Unsupported protocol version: #{version}. Supported versions: 2024-11-05, 2024-10-07"}
  end

  defp dispatch_method("initialize", params) do
    client_info = Map.get(params, "clientInfo", %{})
    protocol_version = Map.get(params, "protocolVersion", "2024-11-05")
    capabilities = Map.get(params, "capabilities", %{})

    Logger.info("MCP Initialize request from client: #{inspect(client_info)}")
    Logger.info("Protocol version: #{protocol_version}")
    Logger.info("Client capabilities: #{inspect(capabilities)}")

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

  defp dispatch_method("prompts/list", _params) do
    {:ok, %{"prompts" => []}}
  end

  defp dispatch_method("resources/list", _params) do
    {:ok, %{"resources" => []}}
  end

  defp dispatch_method("tools/list", _params) do
    {:ok, MCPServer.Tools.get_tools_list()}
  end

  defp dispatch_method("tools/call", params) do
    MCPServer.Tools.dispatch_tool_call(params)
  end

  defp dispatch_method(method, _params) do
    {:error, -32601, "Method not found: #{method}"}
  end

  defp create_error_response(id, code, message) do
    %{
      "jsonrpc" => "2.0",
      "error" => %{
        "code" => code,
        "message" => message
      },
      "id" => id
    }
  end

  def tools_updated do
    notify_all(%{
      "jsonrpc" => "2.0",
      "method" => "notifications/tools/list_changed"
    })
  end

  def notify_all(notification) do
    procs = DynamicSupervisor.which_children(MCPServer.ClientSupervisor)
    # [{:undefined, #PID<0.375.0>, :worker, [MCPServer.ClientHandler]}]

    Enum.each(procs, fn {_id, pid, _type, _modules} ->
      GenServer.cast(pid, {:notification, notification})
    end)
  end
end

defmodule MCPServer.ClientSupervisor do
  use DynamicSupervisor
  require Logger

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_client(socket) do
    child_spec = {MCPServer.ClientHandler, socket}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
end
