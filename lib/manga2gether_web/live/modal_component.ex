defmodule Manga2getherWeb.ModalComponent do
  use Manga2getherWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div id="<%= @id %>"
      class="flex fixed z-10 w-full h-full bg-transparent"
      phx-capture-click="close"
      phx-window-keydown="close"
      phx-key="escape"
      phx-target="#<%= @id %>"
      phx-page-loading>

      <div class="bg-gray-500 p-10 w-4/5 h-1/2 m-auto rounded">
        <%= live_patch raw("&times;"), to: @return_to, class: "float-right" %>
        <%= live_component @socket, @component, @opts %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
