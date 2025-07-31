defmodule SzpakPortfolioWeb.AssistantLive do
  use SzpakPortfolioWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, 
     assign(socket, 
       page_title: "AI Assistant - Stephen Szpak",
       messages: [],
       current_message: "",
       assistant_enabled: false
     )}
  end

  def handle_event("toggle_assistant", _params, socket) do
    {:noreply, assign(socket, assistant_enabled: !socket.assigns.assistant_enabled)}
  end

  def handle_event("update_message", %{"message" => message}, socket) do
    {:noreply, assign(socket, current_message: message)}
  end

  def handle_event("send_message", %{"message" => message}, socket) when byte_size(message) > 0 do
    if socket.assigns.assistant_enabled do
      # In a real implementation, this would call OpenAI API
      new_messages = [
        %{type: :user, content: String.trim(message), timestamp: DateTime.utc_now()},
        %{type: :assistant, content: "This is a placeholder response. The AI assistant is not yet implemented.", timestamp: DateTime.utc_now()}
        | socket.assigns.messages
      ]
      
      {:noreply, assign(socket, messages: new_messages, current_message: "")}
    else
      {:noreply, socket}
    end
  end

  def handle_event("send_message", _params, socket), do: {:noreply, socket}

  def handle_event("clear_chat", _params, socket) do
    {:noreply, assign(socket, messages: [])}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 dark:bg-gray-900 py-20">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- Header -->
        <div class="text-center mb-16 animate-fade-in">
          <h1 class="text-4xl sm:text-5xl font-bold font-display text-gray-900 dark:text-white mb-4">
            AI <span class="text-gradient">Assistant</span>
          </h1>
          <p class="text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
            Chat with an AI assistant about my experience, projects, and technologies
          </p>
        </div>

        <!-- Assistant Toggle -->
        <div class="flex justify-center mb-8">
          <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg text-center">
            <%= if @assistant_enabled do %>
              <div class="flex items-center justify-center space-x-3 mb-4">
                <div class="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
                <span class="text-green-600 dark:text-green-400 font-semibold">Assistant Active</span>
              </div>
            <% else %>
              <div class="flex items-center justify-center space-x-3 mb-4">
                <div class="w-3 h-3 bg-gray-400 rounded-full"></div>
                <span class="text-gray-500 dark:text-gray-400 font-semibold">Assistant Disabled</span>
              </div>
            <% end %>
            
            <p class="text-sm text-gray-600 dark:text-gray-300 mb-4">
              <%= if @assistant_enabled do %>
                The AI assistant is ready to answer questions about Stephen's work and experience.
              <% else %>
                Enable the AI assistant to start chatting. This feature requires an OpenAI API key.
              <% end %>
            </p>
            
            <button
              phx-click="toggle_assistant"
              class={[
                "px-6 py-3 rounded-lg font-semibold transition-all duration-200",
                @assistant_enabled && "bg-red-600 hover:bg-red-700 text-white",
                !@assistant_enabled && "bg-primary-600 hover:bg-primary-700 text-white"
              ]}
            >
              <%= if @assistant_enabled do %>
                <.icon name="hero-pause" class="w-5 h-5 inline mr-2" />
                Disable Assistant
              <% else %>
                <.icon name="hero-play" class="w-5 h-5 inline mr-2" />
                Enable Assistant
              <% end %>
            </button>
          </div>
        </div>

        <%= if @assistant_enabled do %>
          <!-- Chat Interface -->
          <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl overflow-hidden animate-slide-up">
            <!-- Chat Header -->
            <div class="bg-primary-600 dark:bg-primary-700 px-6 py-4 flex items-center justify-between">
              <div class="flex items-center space-x-3">
                <div class="w-8 h-8 bg-white bg-opacity-20 rounded-full flex items-center justify-center">
                  <.icon name="hero-chat-bubble-left-ellipsis" class="w-5 h-5 text-white" />
                </div>
                <div>
                  <h3 class="text-white font-semibold">Stephen's AI Assistant</h3>
                  <p class="text-primary-100 text-sm">Ask me anything about Stephen's work!</p>
                </div>
              </div>
              
              <%= if length(@messages) > 0 do %>
                <button
                  phx-click="clear_chat"
                  class="text-primary-100 hover:text-white transition-colors"
                  title="Clear chat"
                >
                  <.icon name="hero-trash" class="w-5 h-5" />
                </button>
              <% end %>
            </div>

            <!-- Messages -->
            <div class="h-96 overflow-y-auto p-6 space-y-4" id="chat-messages">
              <%= if length(@messages) == 0 do %>
                <div class="text-center text-gray-500 dark:text-gray-400 py-8">
                  <.icon name="hero-chat-bubble-oval-left-ellipsis" class="w-12 h-12 mx-auto mb-4 opacity-50" />
                  <p>Start a conversation! Ask me about Stephen's projects, experience, or technologies.</p>
                  <div class="mt-6 space-y-2">
                    <p class="text-sm font-medium">Try asking:</p>
                    <div class="flex flex-wrap gap-2 justify-center">
                      <span class="text-xs bg-gray-100 dark:bg-gray-700 px-3 py-1 rounded-full">"What projects has Stephen worked on?"</span>
                      <span class="text-xs bg-gray-100 dark:bg-gray-700 px-3 py-1 rounded-full">"What technologies does he use?"</span>
                      <span class="text-xs bg-gray-100 dark:bg-gray-700 px-3 py-1 rounded-full">"Tell me about his experience"</span>
                    </div>
                  </div>
                </div>
              <% else %>
                <%= for message <- Enum.reverse(@messages) do %>
                  <div class={[
                    "flex",
                    message.type == :user && "justify-end",
                    message.type == :assistant && "justify-start"
                  ]}>
                    <div class={[
                      "max-w-xs lg:max-w-md px-4 py-2 rounded-2xl",
                      message.type == :user && "bg-primary-600 text-white",
                      message.type == :assistant && "bg-gray-100 dark:bg-gray-700 text-gray-900 dark:text-white"
                    ]}>
                      <p class="text-sm"><%= message.content %></p>
                      <p class={[
                        "text-xs mt-1",
                        message.type == :user && "text-primary-100",
                        message.type == :assistant && "text-gray-500 dark:text-gray-400"
                      ]}>
                        <%= Calendar.strftime(message.timestamp, "%I:%M %p") %>
                      </p>
                    </div>
                  </div>
                <% end %>
              <% end %>
            </div>

            <!-- Message Input -->
            <div class="border-t border-gray-200 dark:border-gray-700 p-4">
              <form phx-submit="send_message" class="flex space-x-3">
                <input
                  type="text"
                  name="message"
                  value={@current_message}
                  phx-change="update_message"
                  placeholder="Ask me about Stephen's work..."
                  class="flex-1 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 dark:bg-gray-700 dark:text-white"
                  autocomplete="off"
                />
                <button
                  type="submit"
                  disabled={String.trim(@current_message) == ""}
                  class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors"
                >
                  <.icon name="hero-paper-airplane" class="w-5 h-5" />
                </button>
              </form>
            </div>
          </div>
        <% else %>
          <!-- Disabled State -->
          <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl p-8 text-center">
            <div class="w-16 h-16 bg-gray-100 dark:bg-gray-700 rounded-full flex items-center justify-center mx-auto mb-6">
              <.icon name="hero-cpu-chip" class="w-8 h-8 text-gray-400" />
            </div>
            <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-4">
              AI Assistant (Development Mode)
            </h3>
            <p class="text-gray-600 dark:text-gray-300 mb-6 max-w-md mx-auto">
              This AI assistant is scaffolded and ready for integration with OpenAI's API. 
              Enable it above to start a conversation about Stephen's work and experience.
            </p>
            <div class="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg p-4 max-w-md mx-auto">
              <p class="text-yellow-800 dark:text-yellow-300 text-sm">
                <strong>Note:</strong> This feature requires an OpenAI API key to be configured in the environment variables.
              </p>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end