defmodule SzpakPortfolioWeb.ContactLive do
  use SzpakPortfolioWeb, :live_view
  
  alias SzpakPortfolio.{Emails, SpamProtection}

  def mount(_params, _session, socket) do
    changeset = contact_changeset(%{})
    
    {:ok, 
     assign(socket, 
       page_title: "Contact - Stephen Szpak",
       form: to_form(changeset, as: :contact),
       message_sent: false,
       error_message: nil,
       form_start_time: System.system_time(:millisecond)
     )}
  end

  def handle_event("validate", %{"contact" => contact_params}, socket) do
    changeset = contact_changeset(contact_params)
    {:noreply, assign(socket, form: to_form(changeset, as: :contact, action: :validate))}
  end

  def handle_event("send_message", %{"contact" => contact_params}, socket) do
    changeset = contact_changeset(contact_params)
    
    if changeset.valid? do
      # Get client IP for rate limiting
      client_ip = get_connect_info(socket, :peer_data) |> get_ip_string()
      
      # Prepare metadata for spam protection
      metadata = %{
        ip: client_ip,
        form_start_time: socket.assigns.form_start_time
      }
      
      # Check spam protection
      case SpamProtection.validate_submission(contact_params, metadata) do
        :ok ->
          # Attempt to send email
          case Emails.send_contact_email(contact_params) do
            {:ok, :sent} ->
              {:noreply, 
               assign(socket, 
                 message_sent: true,
                 error_message: nil,
                 form: to_form(contact_changeset(%{}), as: :contact)
               )}
            {:error, _reason} ->
              {:noreply, 
               assign(socket, 
                 error_message: "Failed to send message. Please try again later or email me directly.",
                 form: to_form(changeset, as: :contact, action: :validate)
               )}
          end
        
        {:error, reason} ->
          {:noreply, 
           assign(socket, 
             error_message: "Message blocked: #{reason}",
             form: to_form(changeset, as: :contact, action: :validate)
           )}
      end
    else
      {:noreply, assign(socket, form: to_form(changeset, as: :contact, action: :validate))}
    end
  end

  def handle_event("reset_form", _params, socket) do
    {:noreply, 
     assign(socket, 
       message_sent: false, 
       error_message: nil,
       form: to_form(contact_changeset(%{}), as: :contact),
       form_start_time: System.system_time(:millisecond)
     )}
  end

  # Helper function to extract IP address from peer data
  defp get_ip_string(peer_data) do
    case peer_data do
      %{address: address} when is_tuple(address) ->
        address |> :inet.ntoa() |> to_string()
      _ ->
        "unknown"
    end
  end

  defp contact_changeset(attrs) do
    types = %{name: :string, email: :string, subject: :string, message: :string, website: :string}
    
    {%{}, types}
    |> Ecto.Changeset.cast(attrs, [:name, :email, :subject, :message, :website])
    |> Ecto.Changeset.validate_required([:name, :email, :subject, :message])
    |> Ecto.Changeset.validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    |> Ecto.Changeset.validate_length(:name, min: 2, max: 100)
    |> Ecto.Changeset.validate_length(:subject, min: 5, max: 200)
    |> Ecto.Changeset.validate_length(:message, min: 10, max: 1000)
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 dark:bg-gray-900 py-20">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- Header -->
        <div class="text-center mb-16 animate-fade-in">
          <h1 class="text-4xl sm:text-5xl font-bold font-display text-gray-900 dark:text-white mb-4">
            Get In <span class="text-gradient">Touch</span>
          </h1>
          <p class="text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
            Have a project in mind or want to discuss opportunities? I'd love to hear from you!
          </p>
        </div>

        <div class="grid lg:grid-cols-2 gap-12">
          <!-- Contact Information -->
          <div class="space-y-8 animate-slide-up">
            <div>
              <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-6">
                Let's Connect
              </h2>
              <p class="text-gray-600 dark:text-gray-300 leading-relaxed mb-8">
                I'm always interested in discussing new opportunities, collaborating on exciting projects, 
                or just having a chat about technology and development. Feel free to reach out!
              </p>
            </div>

            <!-- Contact Methods -->
            <div class="space-y-6">
              <div class="flex items-center space-x-4 p-4 bg-white dark:bg-gray-800 rounded-lg shadow-md hover:shadow-lg transition-shadow">
                <div class="w-12 h-12 bg-primary-100 dark:bg-primary-900 rounded-lg flex items-center justify-center">
                  <.icon name="hero-envelope" class="w-6 h-6 text-primary-600 dark:text-primary-400" />
                </div>
                <div>
                  <h3 class="font-semibold text-gray-900 dark:text-white">Email</h3>
                  <a href="mailto:stephen@stephenszpak.com" class="text-primary-600 dark:text-primary-400 hover:underline">
                    stephen@stephenszpak.com
                  </a>
                </div>
              </div>

              <div class="flex items-center space-x-4 p-4 bg-white dark:bg-gray-800 rounded-lg shadow-md hover:shadow-lg transition-shadow">
                <div class="w-12 h-12 bg-primary-100 dark:bg-primary-900 rounded-lg flex items-center justify-center">
                  <.icon name="hero-code-bracket" class="w-6 h-6 text-primary-600 dark:text-primary-400" />
                </div>
                <div>
                  <h3 class="font-semibold text-gray-900 dark:text-white">GitHub</h3>
                  <a href="https://github.com/stephenszpak" target="_blank" class="text-primary-600 dark:text-primary-400 hover:underline">
                    github.com/stephenszpak
                  </a>
                </div>
              </div>

              <div class="flex items-center space-x-4 p-4 bg-white dark:bg-gray-800 rounded-lg shadow-md hover:shadow-lg transition-shadow">
                <div class="w-12 h-12 bg-primary-100 dark:bg-primary-900 rounded-lg flex items-center justify-center">
                  <.icon name="hero-user-group" class="w-6 h-6 text-primary-600 dark:text-primary-400" />
                </div>
                <div>
                  <h3 class="font-semibold text-gray-900 dark:text-white">LinkedIn</h3>
                  <a href="https://linkedin.com/in/stephen-szpak" target="_blank" class="text-primary-600 dark:text-primary-400 hover:underline">
                    linkedin.com/in/stephen-szpak
                  </a>
                </div>
              </div>
            </div>

            <!-- Availability -->
            <div class="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg p-4">
              <div class="flex items-center space-x-3">
                <div class="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                <span class="text-green-800 dark:text-green-300 font-medium">
                  Available for new projects
                </span>
              </div>
            </div>
          </div>

          <!-- Contact Form -->
          <div class="animate-slide-up" style="animation-delay: 0.1s;">
            <%= if @message_sent do %>
              <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl p-8 text-center">
                <div class="w-16 h-16 bg-green-100 dark:bg-green-900 rounded-full flex items-center justify-center mx-auto mb-4">
                  <.icon name="hero-check-circle" class="w-8 h-8 text-green-600 dark:text-green-400" />
                </div>
                <h3 class="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                  Message Sent Successfully!
                </h3>
                <p class="text-gray-600 dark:text-gray-300 mb-6">
                  Thank you for reaching out! I'll get back to you as soon as possible.
                </p>
                <button 
                  phx-click="reset_form"
                  class="inline-flex items-center px-6 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
                >
                  Send Another Message
                </button>
              </div>
            <% else %>
              <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl p-8">
                <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-6">
                  Send Me a Message
                </h2>

                <%= if @error_message do %>
                  <div class="mb-6 p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg">
                    <div class="flex items-center space-x-2">
                      <.icon name="hero-exclamation-triangle" class="w-5 h-5 text-red-600 dark:text-red-400" />
                      <span class="text-red-800 dark:text-red-300 font-medium">
                        <%= @error_message %>
                      </span>
                    </div>
                  </div>
                <% end %>

                <.form for={@form} phx-change="validate" phx-submit="send_message" class="space-y-6">
                  <div class="grid sm:grid-cols-2 gap-4">
                    <div>
                      <.input
                        field={@form[:name]}
                        type="text"
                        label="Name"
                        placeholder="Your name"
                        required
                      />
                    </div>
                    <div>
                      <.input
                        field={@form[:email]}
                        type="email"
                        label="Email"
                        placeholder="your@email.com"
                        required
                      />
                    </div>
                  </div>

                  <div>
                    <.input
                      field={@form[:subject]}
                      type="text"
                      label="Subject"
                      placeholder="What's this about?"
                      required
                    />
                  </div>

                  <div>
                    <.input
                      field={@form[:message]}
                      type="textarea"
                      label="Message"
                      placeholder="Tell me about your project or inquiry..."
                      rows="6"
                      required
                    />
                  </div>

                  <!-- Honeypot field - hidden from users but visible to bots -->
                  <div style="position: absolute; left: -9999px; visibility: hidden;">
                    <.input
                      field={@form[:website]}
                      type="text"
                      label="Website (do not fill)"
                      placeholder=""
                      tabindex="-1"
                      autocomplete="off"
                    />
                  </div>

                  <div>
                    <.button
                      type="submit"
                      class="w-full bg-primary-600 hover:bg-primary-700 text-white font-semibold py-3 px-6 rounded-lg transition-colors duration-200 flex items-center justify-center space-x-2"
                    >
                      <.icon name="hero-paper-airplane" class="w-5 h-5" />
                      <span>Send Message</span>
                    </.button>
                  </div>
                </.form>
              </div>
            <% end %>
          </div>
        </div>

        <!-- FAQ Section -->
        <div class="mt-20 bg-white dark:bg-gray-800 rounded-2xl shadow-xl p-8">
          <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-8 text-center">
            Frequently Asked Questions
          </h2>
          
          <div class="grid md:grid-cols-2 gap-8">
            <div>
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">
                What's your typical response time?
              </h3>
              <p class="text-gray-600 dark:text-gray-300">
                I usually respond to messages within 24-48 hours during business days.
              </p>
            </div>

            <div>
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">
                What types of projects do you work on?
              </h3>
              <p class="text-gray-600 dark:text-gray-300">
                I specialize in web applications, particularly those built with Phoenix LiveView, React, and Node.js.
              </p>
            </div>

            <div>
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">
                Do you work with international clients?
              </h3>
              <p class="text-gray-600 dark:text-gray-300">
                Yes! I work with clients globally and am experienced with remote collaboration.
              </p>
            </div>

            <div>
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">
                What's your approach to new projects?
              </h3>
              <p class="text-gray-600 dark:text-gray-300">
                I start with understanding your goals, then propose solutions that fit your timeline and budget.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
