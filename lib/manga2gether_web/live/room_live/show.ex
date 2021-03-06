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

    # room doesnt exist anymore, redirect to dashboard
    if room == nil do
      {:ok,
       socket
       |> put_flash(:error, "That room is no longer available.")
       |> push_redirect(to: Routes.dashboard_index_path(socket, :index))}
    else
      color = RoomUser.assign_color()

      if connected?(socket) do
        room_user = RoomUser.new(%{username: user.username, color: color})
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
       |> assign(:color, color)
       |> assign(:owner, RoomServer.is_owner(room_code, user.id))
       |> assign(:users, users.users)
       |> assign(:chat, "")
       |> assign(:messages, []), temporary_assigns: [messages: []]}
    end

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
      RoomUser.new(%{
        username: socket.assigns.current_user.username,
        color: socket.assigns.color,
        ready: false
      })
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

  ### Room user is told to change reading status
  @impl true
  def handle_info(%{event: "reading_status", payload: %{reading: status}} = _message, socket) do
    {:noreply,
     socket
     |> assign(:current_room, %{socket.assigns.current_room | reading: status})}
  end

  @impl true
  def handle_info(%{event: "set_manga", payload: %{manga: new_manga}} = _message, socket) do
    {:noreply,
     socket
     |> assign(:current_room, %{socket.assigns.current_room | manga: new_manga})}
  end

  @impl true
  def handle_info(%{event: "new_manga_page", payload: %{manga: new_manga}} = _message, socket) do
    {:noreply,
     socket
     |> assign(:current_room, %{socket.assigns.current_room | manga: new_manga})}
  end

  @impl true
  def handle_info(%{event: "end_room"} = _message, socket) do
    # redirect to home
    {:noreply,
      socket
      |> put_flash(:error, "The owner has ended this room.")
      |> push_redirect(to: Routes.dashboard_index_path(socket, :index))}
  end

  @impl true
  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  ################################################################################

  ### Clear chat input
  @impl true
  def handle_event("set_chat", %{"chat_message" => %{"chat" => message}} = _params, socket) do
    {:noreply,
      socket
      |> assign(:chat, message)}
  end

  ### Room user sends chat message
  @impl true
  def handle_event("send_chat", %{"chat_message" => %{"chat" => message}} = _params, socket) do
    if String.length(message) > 0 do
      broadcast!(socket.assigns.current_room.room_code, "new_message", %{
        id: Ecto.UUID.generate(),
        sender: socket.assigns.current_user.username,
        color: socket.assigns.color,
        message: message
      })
    end

    {:noreply,
      socket
      |> assign(:chat, "")}
  end

  ### Room user clicks ready button
  @impl true
  def handle_event("ready", _params, socket) do
    # IO.inspect(params)

    Manga2getherWeb.Presence.update(
      self(),
      "room:#{socket.assigns.current_room.room_code}",
      socket.assigns.current_user.id,
      RoomUser.new(%{
        username: socket.assigns.current_user.username,
        color: socket.assigns.color,
        ready: true
      })
    )

    {:noreply, socket}
  end

  ### Owner changes page and tells room to update their presence
  @impl true
  def handle_event("next_page", _params, socket) do
    broadcast!(socket.assigns.current_room.room_code, "reset_ready", nil)
    RoomServer.next_page(socket.assigns.current_room.room_code)
    # tell reader component to change page

    {:noreply, socket}
  end

  ### Owner changes page and tells room to update their presence
  @impl true
  def handle_event("prev_page", _params, socket) do
    broadcast!(socket.assigns.current_room.room_code, "reset_ready", nil)
    RoomServer.prev_page(socket.assigns.current_room.room_code)
    {:noreply, socket}
  end

  ### Owner changes room status to searching
  @impl true
  def handle_event("show_search", _params, socket) do
    # reset room server manga session
    # broadcast room reading state change
    RoomServer.set_reading(socket.assigns.current_room.room_code, false)
    {:noreply, socket}
  end

  ### User leaves room
  @impl true
  def handle_event("leave_room", _params, socket) do
    {:noreply, push_redirect(socket, to: Routes.dashboard_index_path(socket, :index))}
  end

  ### Owner ends room
  @impl true
  def handle_event("end_room", _params, socket) do
    RoomServer.end_room(socket.assigns.current_room.room_code)
    {:noreply, socket}
  end
end
