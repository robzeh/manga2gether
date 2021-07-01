defmodule Manga2getherWeb.RoomLive.Show do
  use Manga2getherWeb, :live_view

  alias Manga2gether.Accounts
  alias Manga2gether.RoomServer
  alias Manga2gether.RoomUser

  @impl true
  def mount(
        %{"room_code" => room_code} = _params,
        %{"user_token" => session_token} = _session,
        socket
      ) do
    user = assign_user(socket, session_token) |> Map.get(:assigns) |> Map.get(:current_user)
    room = RoomServer.get_room(String.to_integer(room_code))

    if connected?(socket) do
      room_user = RoomUser.new(%{username: user.username})
      Manga2getherWeb.Endpoint.subscribe("room:#{room_code}")

      Manga2getherWeb.Presence.track(
        self(),
        "room:#{room_code}",
        user.id,
        room_user
      )
    end

    # TODO: redo
    users = room_code |> String.to_integer() |> RoomServer.get_users()

    {:ok,
     socket
     |> assign(:current_room, room)
     |> assign(:current_user, user)
     |> assign(:owner, RoomServer.is_owner(room_code, user.id))
     |> assign(:users, users.users)
     |> assign(:messages, []), temporary_assigns: [messages: []]}
  end

  defp broadcast!(room_code, event, message) do
    Manga2getherWeb.Endpoint.broadcast!("room:#{room_code}", event, message)
  end

  def assign_user(socket, token) do
    assign_new(socket, :current_user, fn ->
      Accounts.get_user_by_session_token(token)
    end)
  end

  ################################################################################

  ### Recieved from RoomServer/presence_diff event
  @impl true
  def handle_info(%{event: "updated_users", payload: %{users: users}} = _message, socket) do
    {:noreply,
     socket
     |> assign(:users, users)}
  end

  ### Room user is told by owner to update their presence
  @impl true
  def handle_info(%{event: "reset_ready", payload: _} = _message, socket) do
    Manga2getherWeb.Presence.update(
      self(),
      "room:#{socket.assigns.current_room.room_code}",
      socket.assigns.current_user.id,
      RoomUser.new(%{username: socket.assigns.current_user.username, ready: false})
    )

    {:noreply, socket}
  end

  ### Room user gets chat message
  @impl true
  def handle_info(%{event: "new_message", payload: payload} = _message, socket) do
    socket =
      socket
      |> update(:messages, fn messages -> [payload | messages] end)

    {:noreply, socket}
  end

  @impl true
  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  ################################################################################

  ### Room user sends chat message
  @impl true
  def handle_event("send_chat", %{"chat_message" => %{"message" => message}}, socket) do
    broadcast!(socket.assigns.current_room.room_code, "new_message", %{
      id: Ecto.UUID.generate(),
      sender: socket.assigns.current_user.username,
      message: message
    })

    {:noreply, socket}
  end

  ### Room user clicks ready button
  @impl true
  def handle_event("ready", _params, socket) do
    # IO.inspect(params)

    Manga2getherWeb.Presence.update(
      self(),
      "room:#{socket.assigns.current_room.room_code}",
      socket.assigns.current_user.id,
      RoomUser.new(%{username: socket.assigns.current_user.username, ready: true})
    )

    {:noreply, socket}
  end

  ### Owner tells room to update their presence
  @impl true
  def handle_event("next_page", _params, socket) do
    broadcast!(socket.assigns.current_room.room_code, "reset_ready", nil)

    {:noreply, socket}
  end
end
