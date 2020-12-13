defmodule MultiEditWeb.SessionChannel do
  use MultiEditWeb, :channel

  alias MultiEdit.Session

  intercept ["update"]

  @impl true
  def join("session:lobby", payload, socket) do
    if authorized?(payload) do
      send(self(), :after_join)

      user = %{
        id: payload["id"],
        name: payload["name"],
        colors: {payload["primaryColor"], payload["textColor"]}
      }

      {:ok, assign(socket, :user, user)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_info(:after_join, socket) do
    user = socket.assigns.user

    {:ok, state} = Session.sign_in(user)

    broadcast_state(socket, state)

    {:noreply, socket}
  end

  @impl true
  def handle_in("move_to", payload, socket) do
    {:ok, state} = Session.move_to(socket.assigns.user.id, payload["field"], payload["position"])

    broadcast_state(socket, state)

    {:noreply, socket}
  end

  @impl true
  def handle_in("insert", payload, socket) do
    {:ok, state} = Session.insert(socket.assigns.user.id, payload["field"], payload["text"])

    broadcast_state(socket, state)

    {:noreply, socket}
  end

  @impl true
  def handle_in("delete", payload, socket) do
    {:ok, state} = Session.delete(socket.assigns.user.id, payload["field"])

    broadcast_state(socket, state)

    {:noreply, socket}
  end

  @impl true
  def handle_in("backspace", payload, socket) do
    {:ok, state} = Session.backspace(socket.assigns.user.id, payload["field"])

    broadcast_state(socket, state)

    {:noreply, socket}
  end

  @impl true
  def handle_in("move_x", payload, socket) do
    {:ok, state} = Session.move_x(socket.assigns.user.id, payload["field"], payload["delta"])

    broadcast_state(socket, state)

    {:noreply, socket}
  end

  @impl true
  def handle_in("move_y", payload, socket) do
    {:ok, state} = Session.move_y(socket.assigns.user.id, payload["field"], payload["delta"])

    broadcast_state(socket, state)

    {:noreply, socket}
  end

  @impl true
  def handle_in("select_all", payload, socket) do
    {:ok, state} = Session.select_all(socket.assigns.user.id, payload["field"])

    broadcast_state(socket, state)

    {:noreply, socket}
  end

  @impl true
  def handle_in("select_x", payload, socket) do
    {:ok, state} = Session.select_x(socket.assigns.user.id, payload["field"], payload["delta"])

    broadcast_state(socket, state)

    {:noreply, socket}
  end

  @impl true
  def handle_in("select_y", payload, socket) do
    {:ok, state} = Session.select_y(socket.assigns.user.id, payload["field"], payload["delta"])

    broadcast_state(socket, state)

    {:noreply, socket}
  end

  @impl true
  def handle_out("update", payload, socket) do
    push(socket, "update", Map.merge(payload, %{userId: socket.assigns.user.id}))

    {:noreply, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    {:ok, state} = Session.sign_out(socket.assigns.user.id)

    broadcast_state(socket, state)

    {:stop, :shutdown, socket}
  end

  defp broadcast_state(socket, state) do
    user = socket.assigns.user

    IO.inspect state

    broadcast(socket, "update", %{
      fields: Enum.reduce(state.fields, %{}, fn {id, data}, acc ->
        Map.put(acc, id, data)
      end),
      cursors: Enum.reduce(state.cursors, %{}, fn {id, {field, position}}, acc ->
        Map.put(acc, id, %{field => position})
      end),
      selections: state.selections,
      users: Enum.reduce(state.users, %{}, fn {id, user}, acc ->
        Map.put(acc, id, %{
          id: id,
          name: user.name,
          primaryColor: elem(user.colors, 0),
          textColor: elem(user.colors, 1)
        })
      end)
    })
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
