defmodule SzpakPortfolioWeb.AssistantLive do
  use SzpakPortfolioWeb, :live_view
  
  alias SzpakPortfolio.OpenAIClient

  def mount(_params, _session, socket) do
    api_key_configured = OpenAIClient.api_key_configured?()
    
    {:ok, 
     assign(socket, 
       page_title: "AI Assistant - Stephen Szpak",
       messages: [],
       current_message: "",
       assistant_enabled: api_key_configured,
       api_key_configured: api_key_configured,
       loading: false
     )}
  end

  def handle_event("toggle_assistant", _params, socket) do
    if socket.assigns.api_key_configured do
      {:noreply, assign(socket, assistant_enabled: !socket.assigns.assistant_enabled)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("update_message", %{"message" => message}, socket) do
    {:noreply, assign(socket, current_message: message)}
  end

  def handle_event("send_message", %{"message" => message}, socket) when byte_size(message) > 0 do
    if socket.assigns.assistant_enabled and not socket.assigns.loading do
      trimmed_message = String.trim(message)
      
      # Add user message immediately
      user_message = %{
        type: :user, 
        content: trimmed_message, 
        timestamp: DateTime.utc_now()
      }
      
      updated_messages = [user_message | socket.assigns.messages]
      
      # Create assistant message placeholder for streaming
      assistant_message = %{
        type: :assistant,
        content: "",
        timestamp: DateTime.utc_now(),
        streaming: true
      }
      
      final_messages = [assistant_message | updated_messages]
      
      # Clear input and set loading state
      socket = assign(socket, 
        messages: final_messages,
        current_message: "",
        loading: true
      )
      
      # Send async request to OpenAI
      send(self(), {:send_to_openai, trimmed_message})
      
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("send_message", _params, socket), do: {:noreply, socket}

  def handle_event("clear_chat", _params, socket) do
    {:noreply, assign(socket, messages: [], loading: false)}
  end

  def handle_info({:send_to_openai, user_message}, socket) do
    # Convert messages to OpenAI format (excluding the streaming assistant message)
    openai_messages = 
      socket.assigns.messages
      |> Enum.drop(1) # Remove the streaming assistant message placeholder
      |> Enum.reverse()
      |> Enum.map(fn msg ->
        role = if msg.type == :user, do: "user", else: "assistant"
        %{role: role, content: msg.content}
      end)
    
    # Add the current user message
    openai_messages = openai_messages ++ [%{role: "user", content: user_message}]
    
    case OpenAIClient.chat_completion(openai_messages) do
      {:ok, response} ->
        assistant_content = get_in(response, ["choices", Access.at(0), "message", "content"]) || "Sorry, I couldn't generate a response."
        
        # Update the assistant message with the response
        updated_messages = 
          socket.assigns.messages
          |> List.update_at(0, fn msg ->
            %{msg | content: assistant_content, streaming: false}
          end)
        
        {:noreply, assign(socket, messages: updated_messages, loading: false)}
      
      {:error, error_message} ->
        # Update the assistant message with error
        updated_messages = 
          socket.assigns.messages
          |> List.update_at(0, fn msg ->
            %{msg | content: "Sorry, I encountered an error: #{error_message}", streaming: false}
          end)
        
        {:noreply, assign(socket, messages: updated_messages, loading: false)}
    end
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
            <%= if @api_key_configured do %>
              <%= if @assistant_enabled do %>
                <div class="flex items-center justify-center space-x-3 mb-4">
                  <div class="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
                  <span class="text-green-600 dark:text-green-400 font-semibold">Assistant Active</span>
                </div>
                <p class="text-sm text-gray-600 dark:text-gray-300 mb-4">
                  The AI assistant is ready to answer questions about Stephen's work and experience.
                </p>
              <% else %>
                <div class="flex items-center justify-center space-x-3 mb-4">
                  <div class="w-3 h-3 bg-gray-400 rounded-full"></div>
                  <span class="text-gray-500 dark:text-gray-400 font-semibold">Assistant Disabled</span>
                </div>
                <p class="text-sm text-gray-600 dark:text-gray-300 mb-4">
                  Enable the AI assistant to start chatting about Stephen's portfolio.
                </p>
              <% end %>
              
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
            <% else %>
              <div class="flex items-center justify-center space-x-3 mb-4">
                <div class="w-3 h-3 bg-red-500 rounded-full"></div>
                <span class="text-red-600 dark:text-red-400 font-semibold">API Key Required</span>
              </div>
              <p class="text-sm text-gray-600 dark:text-gray-300 mb-4">
                The AI assistant requires an OpenAI API key to be configured in the environment variables.
              </p>
              <div class="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg p-3">
                <p class="text-yellow-800 dark:text-yellow-300 text-xs">
                  <strong>Setup:</strong> Add OPENAI_API_KEY to your environment variables
                </p>
              </div>
            <% end %>
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
                      <%= if Map.get(message, :streaming, false) && message.content == "" do %>
                        <div class="flex items-center space-x-2">
                          <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-primary-600"></div>
                          <p class="text-sm text-gray-500 dark:text-gray-400">Thinking...</p>
                        </div>
                      <% else %>
                        <p class="text-sm whitespace-pre-wrap"><%= message.content %></p>
                      <% end %>
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
                  placeholder={if @loading, do: "AI is thinking...", else: "Ask me about Stephen's work..."}
                  disabled={@loading}
                  class={[
                    "flex-1 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 dark:bg-gray-700 dark:text-white transition-opacity",
                    @loading && "opacity-50 cursor-not-allowed"
                  ]}
                  autocomplete="off"
                />
                <button
                  type="submit"
                  disabled={String.trim(@current_message) == "" || @loading}
                  class={[
                    "px-4 py-2 rounded-lg transition-colors",
                    (@loading || String.trim(@current_message) == "") && "bg-gray-300 dark:bg-gray-600 cursor-not-allowed",
                    (!@loading && String.trim(@current_message) != "") && "bg-primary-600 hover:bg-primary-700 text-white"
                  ]}
                >
                  <%= if @loading do %>
                    <div class="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                  <% else %>
                    <.icon name="hero-paper-airplane" class="w-5 h-5" />
                  <% end %>
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