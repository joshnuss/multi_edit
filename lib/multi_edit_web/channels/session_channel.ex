defmodule MultiEditWeb.SessionChannel do
  use MultiEditWeb, :channel

  @impl true
  def join("session:lobby", payload, socket) do
    if authorized?(payload) do
      send(self, :after_join)

      {:ok, assign(socket, :user, payload)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    push(socket, "update", %{
      userId: socket.assigns.user["id"],
      fields: %{},
      cursors: %{},
      selections: %{},
      users: %{
        socket.assigns.user["id"] => socket.assigns.user
      }
    })
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (session:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
