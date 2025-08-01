defmodule SzpakPortfolioWeb.HomeLive do
  use SzpakPortfolioWeb, :live_view
  
  alias SzpakPortfolio.OpenAIClient

  def mount(_params, _session, socket) do
    # Technologies data
    technologies = %{
      ai_ml: [
        %{name: "OpenAI API", level: 95, description: "GPT-4, ChatGPT, and DALL-E integrations for intelligent applications"},
        %{name: "Claude API", level: 90, description: "Anthropic's Claude for advanced reasoning and code generation"},
        %{name: "LLM Integration", level: 90, description: "Building conversational AI and intelligent workflows"},
        %{name: "AI Workflows", level: 85, description: "Designing and implementing AI-powered business processes"},
        %{name: "Prompt Engineering", level: 90, description: "Optimizing prompts for better AI responses and reliability"},
        %{name: "Vector Databases", level: 75, description: "Embeddings and semantic search implementations"},
      ],
      backend: [
        %{name: "Elixir", level: 90, description: "Functional programming language for building scalable applications"},
        %{name: "Phoenix", level: 95, description: "Web framework for building real-time applications"},
        %{name: "Phoenix LiveView", level: 95, description: "Rich, interactive web apps without JavaScript"},
        %{name: "Node.js", level: 85, description: "JavaScript runtime for server-side development"},
        %{name: "PostgreSQL", level: 80, description: "Advanced open-source relational database"},
        %{name: "Redis", level: 75, description: "In-memory data structure store for caching"},
      ],
      frontend: [
        %{name: "React", level: 90, description: "JavaScript library for building user interfaces"},
        %{name: "TypeScript", level: 85, description: "Typed superset of JavaScript"},
        %{name: "TailwindCSS", level: 95, description: "Utility-first CSS framework"},
        %{name: "HTML5", level: 95, description: "Markup language for web pages"},
        %{name: "CSS3", level: 90, description: "Styling language for web applications"},
        %{name: "JavaScript", level: 90, description: "Programming language for web development"},
      ],
      tools: [
        %{name: "Git", level: 90, description: "Version control system"},
        %{name: "Docker", level: 80, description: "Containerization platform"},
        %{name: "Fly.io", level: 85, description: "Platform for deploying applications globally"},
        %{name: "GitHub Actions", level: 75, description: "CI/CD platform for automation"},
        %{name: "VS Code", level: 95, description: "Code editor with extensive extensions"},
        %{name: "Figma", level: 70, description: "Design tool for UI/UX design"},
      ]
    }

    # Projects data
    projects = [
      %{
        id: 1,
        title: "Portfolio Website",
        description: "A modern, responsive portfolio website built with Phoenix LiveView and TailwindCSS.",
        long_description: "This portfolio website showcases the power of Phoenix LiveView for creating interactive, real-time web applications. Features include dark mode, responsive design, and smooth animations.",
        image: "/images/projects/portfolio.jpg",
        technologies: ["Phoenix LiveView", "Elixir", "TailwindCSS", "Heroicons"],
        github_url: "https://github.com/stephenszpak/portfolio",
        live_url: "https://stephenszpak.dev",
        status: "completed"
      },
      %{
        id: 2,
        title: "MMO-Server",
        description: "Experimental multiplayer game server built with Phoenix, featuring real-time gameplay mechanics.",
        long_description: "A Phoenix-based multiplayer server experiment demonstrating scalable game architecture. Features include distributed player management with Horde, real-time zone-based gameplay, NPC AI systems with patrolling and combat behaviors, quest tracking and completion, skill systems with JSON metadata, loot dropping and pickup mechanics, world events and boss spawning, player progression (XP/leveling), and comprehensive combat engine with debuff systems. The server uses Phoenix Channels for real-time communication, GenServer processes for players and NPCs, and PubSub for broadcasting world events. Includes clustering support for multi-node deployment and comprehensive test coverage for all game mechanics.",
        image: "/images/projects/mmo-server.jpg",
        technologies: ["Phoenix", "Elixir", "Horde", "PostgreSQL", "Phoenix PubSub", "GenServer"],
        github_url: "https://github.com/stephenszpak/mmo-server",
        live_url: nil,
        status: "completed"
      },
      %{
        id: 3,
        title: "E-commerce Platform",
        description: "Full-featured e-commerce platform with payment processing and inventory management.",
        long_description: "A comprehensive e-commerce solution featuring product catalog, shopping cart, payment processing with Stripe, order management, and admin dashboard. Built with Phoenix LiveView for interactive user experience.",
        image: "/images/projects/ecommerce.jpg",
        technologies: ["Phoenix LiveView", "Elixir", "PostgreSQL", "Stripe API"],
        github_url: "https://github.com/stephenszpak/phoenix-shop",
        live_url: "https://demo-shop.stephenszpak.dev",
        status: "in_progress"
      },
      %{
        id: 4,
        title: "NL-Dashboard",
        description: "AI-powered analytics dashboard with natural language processing for competitive intelligence.",
        long_description: "A sophisticated Phoenix LiveView application that combines AI-driven sentiment analysis with competitive intelligence. Features automated data collection from social media (Twitter, Reddit) and news feeds, real-time sentiment analysis using OpenAI and local models with Ollama fallbacks, autonomous agent subsystem for pattern recognition and historical analysis, intelligent trigger system for competitor activity monitoring, comprehensive analytics with VegaLite visualizations, conversational AI interface for natural language queries, scheduled data processing with background jobs, and alert system for significant market changes. The dashboard provides actionable insights through AI assistance, making complex data analysis accessible through natural language interactions.",
        image: "/images/projects/nl-dashboard.jpg",
        technologies: ["Phoenix LiveView", "Elixir", "OpenAI", "VegaLite", "Ecto", "Ollama"],
        github_url: "https://github.com/stephenszpak/nl-dashboard",
        live_url: nil,
        status: "completed"
      }
    ]

    # Contact form
    changeset = contact_changeset(%{})
    
    api_key_configured = OpenAIClient.api_key_configured?()

    {:ok, 
     assign(socket, 
       page_title: "Stephen Szpak - AI-Focused Full Stack Developer",
       technologies: technologies,
       selected_category: :ai_ml,
       projects: projects,
       selected_project: nil,
       view_mode: "bio",
       form: to_form(changeset, as: :contact),
       message_sent: false,
       # AI Assistant state
       assistant_open: false,
       assistant_enabled: api_key_configured,
       api_key_configured: api_key_configured,
       messages: [],
       current_message: "",
       loading: false
     )}
  end

  # Event handlers for different sections
  
  # About section handlers
  def handle_event("toggle_view", %{"mode" => mode}, socket) do
    {:noreply, assign(socket, view_mode: mode)}
  end

  # Technologies section handlers
  def handle_event("select_category", %{"category" => category}, socket) do
    {:noreply, assign(socket, selected_category: String.to_atom(category))}
  end

  # Projects section handlers
  def handle_event("open_modal", %{"project_id" => project_id}, socket) do
    project = Enum.find(socket.assigns.projects, &(&1.id == String.to_integer(project_id)))
    {:noreply, assign(socket, selected_project: project)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, selected_project: nil)}
  end

  # Contact form handlers
  def handle_event("validate", %{"contact" => contact_params}, socket) do
    changeset = contact_changeset(contact_params)
    {:noreply, assign(socket, form: to_form(changeset, as: :contact, action: :validate))}
  end

  def handle_event("send_message", %{"contact" => contact_params}, socket) do
    changeset = contact_changeset(contact_params)
    
    if changeset.valid? do
      {:noreply, 
       assign(socket, 
         message_sent: true,
         form: to_form(contact_changeset(%{}), as: :contact)
       )}
    else
      {:noreply, assign(socket, form: to_form(changeset, as: :contact, action: :validate))}
    end
  end

  def handle_event("reset_form", _params, socket) do
    {:noreply, assign(socket, message_sent: false, form: to_form(contact_changeset(%{}), as: :contact))}
  end

  # AI Assistant handlers
  def handle_event("toggle_assistant", _params, socket) do
    if socket.assigns.api_key_configured do
      {:noreply, assign(socket, assistant_open: !socket.assigns.assistant_open)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("close_assistant", _params, socket) do
    {:noreply, assign(socket, assistant_open: false)}
  end

  def handle_event("update_message", %{"message" => message}, socket) do
    {:noreply, assign(socket, current_message: message)}
  end

  def handle_event("send_message_ai", %{"message" => message}, socket) when byte_size(message) > 0 do
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

  def handle_event("send_message_ai", _params, socket), do: {:noreply, socket}

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

  # Contact form changeset
  defp contact_changeset(attrs) do
    types = %{name: :string, email: :string, subject: :string, message: :string}
    
    {%{}, types}
    |> Ecto.Changeset.cast(attrs, [:name, :email, :subject, :message])
    |> Ecto.Changeset.validate_required([:name, :email, :subject, :message])
    |> Ecto.Changeset.validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    |> Ecto.Changeset.validate_length(:name, min: 2, max: 100)
    |> Ecto.Changeset.validate_length(:subject, min: 5, max: 200)
    |> Ecto.Changeset.validate_length(:message, min: 10, max: 1000)
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 dark:bg-gray-900">
      <!-- Hero Section -->
      <section id="home" class="relative min-h-screen flex items-center justify-center px-4 sm:px-6 lg:px-8 overflow-hidden">
        <!-- Animated Background -->
        <div class="absolute inset-0 hero-gradient animate-gradient-shift opacity-20"></div>
        
        <!-- Floating Elements -->
        <div class="absolute inset-0 overflow-hidden">
          <!-- Morphing Blobs -->
          <div class="absolute -top-20 -right-20 w-96 h-96 bg-gradient-to-br from-primary-400 to-purple-600 rounded-full mix-blend-multiply filter blur-xl opacity-30 animate-float animate-morph"></div>
          <div class="absolute -bottom-20 -left-20 w-80 h-80 bg-gradient-to-tr from-pink-400 to-orange-500 rounded-full mix-blend-multiply filter blur-xl opacity-25 animate-float-reverse animate-morph" style="animation-delay: 3s;"></div>
          <div class="absolute top-1/2 right-1/4 w-64 h-64 bg-gradient-to-bl from-indigo-400 to-cyan-500 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-float" style="animation-delay: 5s;"></div>
          
          <!-- Particle System -->
          <div class="particle animate-particle-float"></div>
          <div class="particle animate-particle-float"></div>
          <div class="particle animate-particle-float"></div>
          <div class="particle animate-particle-float"></div>
          <div class="particle animate-particle-float"></div>
          <div class="particle animate-particle-float"></div>
        </div>

        <!-- Main Content -->
        <div class="relative z-10 max-w-6xl mx-auto">
          <div class="grid lg:grid-cols-2 gap-12 items-center">
            <!-- Left Column - Text Content -->
            <div class="text-center lg:text-left animate-slide-up-stagger">
              <!-- Profile Image -->
              <div class="flex justify-center lg:justify-start mb-8">
                <div class="profile-glow w-32 h-32 rounded-full overflow-hidden animate-pulse-glow">
                  <div class="w-full h-full bg-gradient-to-br from-primary-400 to-purple-600 rounded-full flex items-center justify-center text-white text-4xl font-bold">
                    SS
                  </div>
                </div>
              </div>

              <h1 class="text-6xl sm:text-7xl lg:text-8xl font-bold font-display mb-6 leading-tight">
                <span class="text-gray-900 dark:text-white text-glow">Stephen</span>
                <br>
                <span class="text-gradient text-glow animate-gradient-shift">Szpak</span>
              </h1>
              
              <!-- Typewriter Effect for Role -->
              <div class="mb-8 h-16 flex items-center justify-center lg:justify-start">
                <div class="text-2xl sm:text-3xl text-primary-600 dark:text-primary-400 font-semibold overflow-hidden whitespace-nowrap border-r-4 border-primary-600 animate-typewriter">
                  AI-Focused Full Stack Developer
                </div>
              </div>

              <p class="text-lg sm:text-xl text-gray-600 dark:text-gray-300 mb-8 max-w-2xl mx-auto lg:mx-0 animate-slide-up-stagger" style="animation-delay: 0.2s;">
                Building intelligent web applications with AI integration, LLMs, and modern technologies. 
                Specializing in <span class="text-primary-600 dark:text-primary-400 font-semibold">OpenAI</span> and <span class="text-primary-600 dark:text-primary-400 font-semibold">Claude</span> integrations.
              </p>

              <!-- Skill Tags -->
              <div class="flex flex-wrap justify-center lg:justify-start gap-3 mb-12 animate-slide-up-stagger" style="animation-delay: 0.4s;">
                <span class="skill-tag px-4 py-2 bg-gradient-to-r from-purple-100 to-pink-100 dark:from-purple-900 dark:to-pink-900 text-purple-800 dark:text-purple-200 rounded-full text-sm font-medium animate-slide-up-stagger" style="--delay: 0.1s;">OpenAI API</span>
                <span class="skill-tag px-4 py-2 bg-gradient-to-r from-blue-100 to-indigo-100 dark:from-blue-900 dark:to-indigo-900 text-blue-800 dark:text-blue-200 rounded-full text-sm font-medium animate-slide-up-stagger" style="--delay: 0.2s;">Claude API</span>
                <span class="skill-tag px-4 py-2 bg-primary-100 dark:bg-primary-900 text-primary-800 dark:text-primary-200 rounded-full text-sm font-medium animate-slide-up-stagger" style="--delay: 0.3s;">Phoenix LiveView</span>
                <span class="skill-tag px-4 py-2 bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200 rounded-full text-sm font-medium animate-slide-up-stagger" style="--delay: 0.4s;">LLM Integration</span>
                <span class="skill-tag px-4 py-2 bg-orange-100 dark:bg-orange-900 text-orange-800 dark:text-orange-200 rounded-full text-sm font-medium animate-slide-up-stagger" style="--delay: 0.5s;">AI Workflows</span>
              </div>

              <!-- Enhanced CTA Buttons -->
              <div class="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start items-center mb-12 animate-slide-up-stagger" style="animation-delay: 0.6s;">
                <a href="#projects" class="group relative inline-flex items-center px-8 py-4 bg-gradient-to-r from-primary-600 to-purple-600 hover:from-primary-700 hover:to-purple-700 text-white font-semibold rounded-xl transition-all duration-300 shadow-lg hover:shadow-2xl transform hover:-translate-y-1 overflow-hidden">
                  <div class="absolute inset-0 bg-gradient-to-r from-white/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                  <.icon name="hero-rocket-launch" class="w-5 h-5 mr-2 relative z-10" />
                  <span class="relative z-10">View My Work</span>
                </a>
                
                <a href="#contact" class="group inline-flex items-center px-8 py-4 card-gradient text-gray-700 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 font-semibold rounded-xl transition-all duration-300 shadow-lg hover:shadow-2xl transform hover:-translate-y-1">
                  <.icon name="hero-chat-bubble-left-ellipsis" class="w-5 h-5 mr-2 transition-transform group-hover:scale-110" />
                  Get In Touch
                </a>
              </div>

              <!-- Social Links -->
              <div class="flex justify-center lg:justify-start space-x-6 animate-slide-up-stagger" style="animation-delay: 0.8s;">
                <a href="https://github.com/stephenszpak" target="_blank" class="group p-3 card-gradient rounded-full hover:bg-gradient-to-br hover:from-primary-500 hover:to-purple-600 transition-all duration-300 transform hover:-translate-y-2 hover:shadow-xl">
                  <.icon name="hero-code-bracket" class="w-6 h-6 text-gray-600 dark:text-gray-400 group-hover:text-white transition-colors duration-300" />
                </a>
                <a href="https://linkedin.com/in/stephen-szpak" target="_blank" class="group p-3 card-gradient rounded-full hover:bg-gradient-to-br hover:from-primary-500 hover:to-purple-600 transition-all duration-300 transform hover:-translate-y-2 hover:shadow-xl">
                  <.icon name="hero-user-group" class="w-6 h-6 text-gray-600 dark:text-gray-400 group-hover:text-white transition-colors duration-300" />
                </a>
              </div>
            </div>

            <!-- Right Column - Interactive Cards -->
            <div class="lg:block animate-slide-up-stagger" style="animation-delay: 1s;">
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                <!-- AI Integration Card -->
                <div class="tilt-card p-6 card-gradient rounded-2xl shadow-xl animate-slide-up-stagger" style="animation-delay: 1.1s;">
                  <div class="w-12 h-12 bg-gradient-to-br from-purple-500 to-pink-600 rounded-xl flex items-center justify-center mb-4 animate-pulse-glow">
                    <.icon name="hero-cpu-chip" class="w-6 h-6 text-white" />
                  </div>
                  <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-2">AI Integration</h3>
                  <p class="text-sm text-gray-600 dark:text-gray-300">OpenAI & Claude API integrations for intelligent apps</p>
                </div>

                <!-- LLM Applications Card -->
                <div class="tilt-card p-6 card-gradient rounded-2xl shadow-xl animate-slide-up-stagger" style="animation-delay: 1.2s;">
                  <div class="w-12 h-12 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-xl flex items-center justify-center mb-4 animate-pulse-glow">
                    <.icon name="hero-sparkles" class="w-6 h-6 text-white" />
                  </div>
                  <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-2">LLM Apps</h3>
                  <p class="text-sm text-gray-600 dark:text-gray-300">Building conversational AI and intelligent workflows</p>
                </div>

                <!-- Real-time AI Card -->
                <div class="tilt-card p-6 card-gradient rounded-2xl shadow-xl animate-slide-up-stagger" style="animation-delay: 1.3s;">
                  <div class="w-12 h-12 bg-gradient-to-br from-green-500 to-teal-600 rounded-xl flex items-center justify-center mb-4 animate-pulse-glow">
                    <.icon name="hero-lightning-bolt" class="w-6 h-6 text-white" />
                  </div>
                  <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-2">Real-time AI</h3>
                  <p class="text-sm text-gray-600 dark:text-gray-300">Live AI interactions with Phoenix LiveView</p>
                </div>

                <!-- Full Stack AI Card -->
                <div class="tilt-card p-6 card-gradient rounded-2xl shadow-xl animate-slide-up-stagger" style="animation-delay: 1.4s;">
                  <div class="w-12 h-12 bg-gradient-to-br from-orange-500 to-red-600 rounded-xl flex items-center justify-center mb-4 animate-pulse-glow">
                    <.icon name="hero-code-bracket-square" class="w-6 h-6 text-white" />
                  </div>
                  <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-2">Full Stack AI</h3>
                  <p class="text-sm text-gray-600 dark:text-gray-300">End-to-end AI-powered web applications</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Enhanced Scroll Indicator -->
        <div class="absolute bottom-8 left-1/2 transform -translate-x-1/2 animate-bounce">
          <div class="flex flex-col items-center space-y-2">
            <span class="text-xs text-gray-500 dark:text-gray-400 font-medium">Scroll to explore</span>
            <div class="w-6 h-10 border-2 border-gray-400 dark:border-gray-500 rounded-full flex justify-center">
              <div class="w-1 h-3 bg-gray-400 dark:bg-gray-500 rounded-full mt-2 animate-bounce"></div>
            </div>
          </div>
        </div>
      </section>

      <!-- Quick Overview Section -->
      <section class="py-20 px-4 sm:px-6 lg:px-8">
        <div class="max-w-6xl mx-auto">
          <div class="grid md:grid-cols-3 gap-8">
            <div class="text-center p-6 rounded-xl bg-white dark:bg-gray-800 shadow-lg hover:shadow-xl transition-shadow duration-300 animate-slide-up">
              <div class="w-12 h-12 bg-gradient-to-br from-purple-100 to-pink-100 dark:from-purple-900 dark:to-pink-900 rounded-lg flex items-center justify-center mx-auto mb-4">
                <.icon name="hero-cpu-chip" class="w-6 h-6 text-purple-600 dark:text-purple-400" />
              </div>
              <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">AI Integration Specialist</h3>
              <p class="text-gray-600 dark:text-gray-300">Expert in OpenAI and Claude API integrations, building intelligent applications with advanced AI capabilities.</p>
            </div>

            <div class="text-center p-6 rounded-xl bg-white dark:bg-gray-800 shadow-lg hover:shadow-xl transition-shadow duration-300 animate-slide-up" style="animation-delay: 0.1s;">
              <div class="w-12 h-12 bg-gradient-to-br from-blue-100 to-indigo-100 dark:from-blue-900 dark:to-indigo-900 rounded-lg flex items-center justify-center mx-auto mb-4">
                <.icon name="hero-sparkles" class="w-6 h-6 text-blue-600 dark:text-blue-400" />
              </div>
              <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">LLM Applications</h3>
              <p class="text-gray-600 dark:text-gray-300">Creating conversational AI, intelligent workflows, and AI-powered business solutions.</p>
            </div>

            <div class="text-center p-6 rounded-xl bg-white dark:bg-gray-800 shadow-lg hover:shadow-xl transition-shadow duration-300 animate-slide-up" style="animation-delay: 0.2s;">
              <div class="w-12 h-12 bg-gradient-to-br from-green-100 to-teal-100 dark:from-green-900 dark:to-teal-900 rounded-lg flex items-center justify-center mx-auto mb-4">
                <.icon name="hero-lightning-bolt" class="w-6 h-6 text-green-600 dark:text-green-400" />
              </div>
              <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">Real-time AI</h3>
              <p class="text-gray-600 dark:text-gray-300">Building live AI interactions and real-time intelligent applications using Phoenix LiveView.</p>
            </div>
          </div>
        </div>
      </section>

      <!-- About Section -->
      <section id="about" class="py-20 px-4 sm:px-6 lg:px-8">
        <div class="max-w-4xl mx-auto">
          <!-- Header -->
          <div class="text-center mb-16 animate-fade-in">
            <h1 class="text-4xl sm:text-5xl font-bold font-display text-gray-900 dark:text-white mb-4">
              About <span class="text-gradient">Me</span>
            </h1>
            <p class="text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
              Passionate developer with a love for creating exceptional digital experiences
            </p>
          </div>

          <!-- View Toggle -->
          <div class="flex justify-center mb-12">
            <div class="bg-white dark:bg-gray-800 rounded-lg p-1 shadow-md">
              <button
                phx-click="toggle_view"
                phx-value-mode="bio"
                class={[
                  "px-6 py-2 rounded-md font-medium transition-all duration-200",
                  @view_mode == "bio" && "bg-primary-600 text-white shadow-md",
                  @view_mode != "bio" && "text-gray-600 dark:text-gray-300 hover:text-primary-600"
                ]}
              >
                Bio
              </button>
              <button
                phx-click="toggle_view"
                phx-value-mode="timeline"
                class={[
                  "px-6 py-2 rounded-md font-medium transition-all duration-200",
                  @view_mode == "timeline" && "bg-primary-600 text-white shadow-md",
                  @view_mode != "timeline" && "text-gray-600 dark:text-gray-300 hover:text-primary-600"
                ]}
              >
                Timeline
              </button>
            </div>
          </div>

          <!-- About Content -->
          <div class="animate-slide-up">
            <%= if @view_mode == "bio" do %>
              <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl p-8 lg:p-12">
                <div class="grid lg:grid-cols-3 gap-8 items-center">
                  <div class="lg:col-span-1">
                    <div class="w-48 h-48 mx-auto bg-gradient-to-br from-primary-400 to-purple-500 rounded-full flex items-center justify-center text-white text-6xl font-bold shadow-xl">
                      SS
                    </div>
                  </div>
                  
                  <div class="lg:col-span-2 space-y-6">
                    <div>
                      <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-4">
                        Full Stack Developer & Problem Solver
                      </h2>
                      <div class="space-y-4 text-gray-600 dark:text-gray-300 leading-relaxed">
                        <p>
                          With over <strong>5 years of experience</strong> in web development, I specialize in creating 
                          robust, scalable applications using modern technologies. My journey began with traditional 
                          web development and has evolved to embrace cutting-edge frameworks like Phoenix LiveView.
                        </p>
                        <p>
                          I'm passionate about <strong>functional programming</strong> and real-time web applications. 
                          My expertise spans from crafting elegant user interfaces to designing efficient backend 
                          systems and APIs.
                        </p>
                        <p>
                          When I'm not coding, you'll find me exploring new technologies, contributing to open source 
                          projects, or sharing knowledge with the developer community through technical writing and 
                          mentoring.
                        </p>
                      </div>
                    </div>

                    <div class="flex flex-wrap gap-4">
                      <div class="bg-primary-50 dark:bg-primary-900/30 px-4 py-2 rounded-full">
                        <span class="text-primary-700 dark:text-primary-300 font-medium">Phoenix & Elixir</span>
                      </div>
                      <div class="bg-primary-50 dark:bg-primary-900/30 px-4 py-2 rounded-full">
                        <span class="text-primary-700 dark:text-primary-300 font-medium">React & TypeScript</span>
                      </div>
                      <div class="bg-primary-50 dark:bg-primary-900/30 px-4 py-2 rounded-full">
                        <span class="text-primary-700 dark:text-primary-300 font-medium">Node.js</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            <% else %>
              <div class="space-y-8">
                <!-- Timeline Item -->
                <div class="relative pl-8 pb-8 border-l-2 border-primary-200 dark:border-primary-800">
                  <div class="absolute -left-2 top-0 w-4 h-4 bg-primary-600 rounded-full"></div>
                  <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
                    <div class="flex items-center gap-4 mb-3">
                      <span class="text-sm font-semibold text-primary-600 dark:text-primary-400 bg-primary-50 dark:bg-primary-900/30 px-3 py-1 rounded-full">
                        2023 - Present
                      </span>
                    </div>
                    <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2">
                      Senior Full Stack Developer
                    </h3>
                    <p class="text-gray-600 dark:text-gray-300 mb-4">
                      Leading development of enterprise-scale Phoenix LiveView applications, mentoring junior developers, 
                      and driving technical architecture decisions.
                    </p>
                    <div class="flex flex-wrap gap-2">
                      <span class="text-xs bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-2 py-1 rounded">Phoenix LiveView</span>
                      <span class="text-xs bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-2 py-1 rounded">PostgreSQL</span>
                      <span class="text-xs bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-2 py-1 rounded">TailwindCSS</span>
                    </div>
                  </div>
                </div>

                <!-- Timeline Item -->
                <div class="relative pl-8 pb-8 border-l-2 border-primary-200 dark:border-primary-800">
                  <div class="absolute -left-2 top-0 w-4 h-4 bg-primary-600 rounded-full"></div>
                  <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
                    <div class="flex items-center gap-4 mb-3">
                      <span class="text-sm font-semibold text-primary-600 dark:text-primary-400 bg-primary-50 dark:bg-primary-900/30 px-3 py-1 rounded-full">
                        2021 - 2023
                      </span>
                    </div>
                    <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2">
                      Full Stack Developer
                    </h3>
                    <p class="text-gray-600 dark:text-gray-300 mb-4">
                      Developed and maintained React-based web applications, built RESTful APIs with Node.js, 
                      and collaborated with cross-functional teams to deliver high-quality software solutions.
                    </p>
                    <div class="flex flex-wrap gap-2">
                      <span class="text-xs bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-2 py-1 rounded">React</span>
                      <span class="text-xs bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-2 py-1 rounded">Node.js</span>
                      <span class="text-xs bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-2 py-1 rounded">MongoDB</span>
                    </div>
                  </div>
                </div>

                <!-- Timeline Item -->
                <div class="relative pl-8">
                  <div class="absolute -left-2 top-0 w-4 h-4 bg-primary-600 rounded-full"></div>
                  <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
                    <div class="flex items-center gap-4 mb-3">
                      <span class="text-sm font-semibold text-primary-600 dark:text-primary-400 bg-primary-50 dark:bg-primary-900/30 px-3 py-1 rounded-full">
                        2019 - 2021
                      </span>
                    </div>
                    <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2">
                      Frontend Developer
                    </h3>
                    <p class="text-gray-600 dark:text-gray-300 mb-4">
                      Started my professional journey focusing on frontend development, creating responsive user interfaces 
                      and learning the fundamentals of modern web development.
                    </p>
                    <div class="flex flex-wrap gap-2">
                      <span class="text-xs bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-2 py-1 rounded">JavaScript</span>
                      <span class="text-xs bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-2 py-1 rounded">CSS3</span>
                      <span class="text-xs bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 px-2 py-1 rounded">HTML5</span>
                    </div>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </section>

      <!-- Projects Section -->
      <section id="projects" class="py-20 px-4 sm:px-6 lg:px-8 bg-white dark:bg-gray-800">
        <div class="max-w-7xl mx-auto">
          <!-- Header -->
          <div class="text-center mb-16 animate-fade-in">
            <h1 class="text-4xl sm:text-5xl font-bold font-display text-gray-900 dark:text-white mb-4">
              My <span class="text-gradient">Projects</span>
            </h1>
            <p class="text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
              A collection of projects showcasing my skills in web development and problem-solving
            </p>
          </div>

          <!-- Projects Grid -->
          <div class="grid md:grid-cols-2 lg:grid-cols-2 gap-8 mb-16">
            <%= for {project, index} <- Enum.with_index(@projects) do %>
              <div class={[
                "bg-gray-50 dark:bg-gray-900 rounded-2xl shadow-lg hover:shadow-2xl transition-all duration-300 overflow-hidden group cursor-pointer animate-slide-up",
                "hover:-translate-y-2"
              ]} style={"animation-delay: #{index * 0.1}s;"} phx-click="open_modal" phx-value-project_id={project.id}>
                <!-- Project Image Placeholder -->
                <div class="h-48 bg-gradient-to-br from-primary-400 to-purple-500 relative overflow-hidden">
                  <div class="absolute inset-0 bg-black bg-opacity-20 group-hover:bg-opacity-10 transition-all duration-300"></div>
                  <div class="absolute inset-0 flex items-center justify-center text-white">
                    <.icon name="hero-photo" class="w-16 h-16 opacity-60" />
                  </div>
                  <!-- Status Badge -->
                  <div class="absolute top-4 right-4">
                    <span class={[
                      "px-3 py-1 text-xs font-semibold rounded-full",
                      project.status == "completed" && "bg-green-100 text-green-800",
                      project.status == "in_progress" && "bg-yellow-100 text-yellow-800"
                    ]}>
                      <%= String.replace(project.status, "_", " ") |> String.capitalize() %>
                    </span>
                  </div>
                </div>

                <div class="p-6">
                  <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2">
                    <%= project.title %>
                  </h3>
                  <p class="text-gray-600 dark:text-gray-300 mb-4 line-clamp-2">
                    <%= project.description %>
                  </p>

                  <!-- Technologies -->
                  <div class="flex flex-wrap gap-2 mb-4">
                    <%= for tech <- Enum.take(project.technologies, 3) do %>
                      <span class="text-xs bg-primary-50 dark:bg-primary-900/30 text-primary-700 dark:text-primary-300 px-2 py-1 rounded-full">
                        <%= tech %>
                      </span>
                    <% end %>
                    <%= if length(project.technologies) > 3 do %>
                      <span class="text-xs bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-400 px-2 py-1 rounded-full">
                        +<%= length(project.technologies) - 3 %> more
                      </span>
                    <% end %>
                  </div>

                  <!-- Actions -->
                  <div class="flex items-center justify-between">
                    <div class="flex space-x-3">
                      <%= if project.github_url do %>
                        <a href={project.github_url} target="_blank" class="text-gray-500 hover:text-primary-600 dark:hover:text-primary-400 transition-colors" onclick="event.stopPropagation();">
                          <.icon name="hero-code-bracket" class="w-5 h-5" />
                        </a>
                      <% end %>
                      <%= if project.live_url do %>
                        <a href={project.live_url} target="_blank" class="text-gray-500 hover:text-primary-600 dark:hover:text-primary-400 transition-colors" onclick="event.stopPropagation();">
                          <.icon name="hero-arrow-top-right-on-square" class="w-5 h-5" />
                        </a>
                      <% end %>
                    </div>
                    <span class="text-sm text-primary-600 dark:text-primary-400 font-medium group-hover:text-primary-700 dark:group-hover:text-primary-300">
                      View Details →
                    </span>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </section>

      <!-- Technologies Section -->
      <section id="technologies" class="py-20 px-4 sm:px-6 lg:px-8">
        <div class="max-w-6xl mx-auto">
          <!-- Header -->
          <div class="text-center mb-16 animate-fade-in">
            <h1 class="text-4xl sm:text-5xl font-bold font-display text-gray-900 dark:text-white mb-4">
              My <span class="text-gradient">Technologies</span>
            </h1>
            <p class="text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
              Tools and technologies I use to build modern, scalable web applications
            </p>
          </div>

          <!-- Category Selector -->
          <div class="flex justify-center mb-12">
            <div class="bg-white dark:bg-gray-800 rounded-xl p-1 shadow-lg">
              <button
                phx-click="select_category"
                phx-value-category="backend"
                class={[
                  "px-6 py-3 rounded-lg font-medium transition-all duration-200 flex items-center space-x-2",
                  @selected_category == :backend && "bg-primary-600 text-white shadow-md",
                  @selected_category != :backend && "text-gray-600 dark:text-gray-300 hover:text-primary-600 hover:bg-primary-50 dark:hover:bg-primary-900/30"
                ]}
              >
                <.icon name="hero-server" class="w-5 h-5" />
                <span>Backend</span>
              </button>
              <button
                phx-click="select_category"
                phx-value-category="frontend"
                class={[
                  "px-6 py-3 rounded-lg font-medium transition-all duration-200 flex items-center space-x-2",
                  @selected_category == :frontend && "bg-primary-600 text-white shadow-md",
                  @selected_category != :frontend && "text-gray-600 dark:text-gray-300 hover:text-primary-600 hover:bg-primary-50 dark:hover:bg-primary-900/30"
                ]}
              >
                <.icon name="hero-computer-desktop" class="w-5 h-5" />
                <span>Frontend</span>
              </button>
              <button
                phx-click="select_category"
                phx-value-category="tools"
                class={[
                  "px-6 py-3 rounded-lg font-medium transition-all duration-200 flex items-center space-x-2",
                  @selected_category == :tools && "bg-primary-600 text-white shadow-md",
                  @selected_category != :tools && "text-gray-600 dark:text-gray-300 hover:text-primary-600 hover:bg-primary-50 dark:hover:bg-primary-900/30"
                ]}
              >
                <.icon name="hero-wrench-screwdriver" class="w-5 h-5" />
                <span>Tools</span>
              </button>
            </div>
          </div>

          <!-- Technologies Grid -->
          <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            <%= for {tech, index} <- Enum.with_index(@technologies[@selected_category]) do %>
              <div class={[
                "bg-white dark:bg-gray-800 rounded-2xl p-6 shadow-lg hover:shadow-xl transition-all duration-300 animate-slide-up",
                "hover:-translate-y-1"
              ]} style={"animation-delay: #{index * 0.05}s;"}>
                <!-- Technology Header -->
                <div class="flex items-center justify-between mb-4">
                  <h3 class="text-xl font-bold text-gray-900 dark:text-white">
                    <%= tech.name %>
                  </h3>
                  <div class="flex items-center space-x-2">
                    <div class="w-12 h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
                      <div 
                        class="h-full bg-gradient-to-r from-primary-500 to-primary-600 rounded-full transition-all duration-1000"
                        style={"width: #{tech.level}%"}
                      ></div>
                    </div>
                    <span class="text-sm font-semibold text-primary-600 dark:text-primary-400">
                      <%= tech.level %>%
                    </span>
                  </div>
                </div>

                <!-- Technology Description -->
                <p class="text-gray-600 dark:text-gray-300 text-sm leading-relaxed">
                  <%= tech.description %>
                </p>

                <!-- Experience Indicator -->
                <div class="mt-4 flex items-center">
                  <%= for i <- 1..5 do %>
                    <div class={[
                      "w-2 h-2 rounded-full mr-1",
                      (i * 20) <= tech.level && "bg-primary-500",
                      (i * 20) > tech.level && "bg-gray-300 dark:bg-gray-600"
                    ]}></div>
                  <% end %>
                  <span class="ml-2 text-xs text-gray-500 dark:text-gray-400">
                    <%= cond do %>
                      <% tech.level >= 90 -> %>Expert
                      <% tech.level >= 75 -> %>Advanced
                      <% tech.level >= 60 -> %>Intermediate
                      <% true -> %>Beginner
                    <% end %>
                  </span>
                </div>
              </div>
            <% end %>
          </div>

          <!-- Additional Info Section -->
          <div class="mt-20 bg-white dark:bg-gray-800 rounded-2xl p-8 shadow-xl">
            <div class="text-center mb-8">
              <h2 class="text-3xl font-bold text-gray-900 dark:text-white mb-4">
                Always Learning
              </h2>
              <p class="text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
                Technology evolves rapidly, and I'm committed to staying current with the latest trends and best practices in web development.
              </p>
            </div>

            <div class="grid md:grid-cols-3 gap-8">
              <div class="text-center">
                <div class="w-16 h-16 bg-primary-100 dark:bg-primary-900 rounded-full flex items-center justify-center mx-auto mb-4">
                  <.icon name="hero-academic-cap" class="w-8 h-8 text-primary-600 dark:text-primary-400" />
                </div>
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">Continuous Learning</h3>
                <p class="text-gray-600 dark:text-gray-300 text-sm">
                  Regularly exploring new technologies and frameworks to stay ahead of the curve.
                </p>
              </div>

              <div class="text-center">
                <div class="w-16 h-16 bg-primary-100 dark:bg-primary-900 rounded-full flex items-center justify-center mx-auto mb-4">
                  <.icon name="hero-users" class="w-8 h-8 text-primary-600 dark:text-primary-400" />
                </div>
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">Community Involvement</h3>
                <p class="text-gray-600 dark:text-gray-300 text-sm">
                  Active in developer communities, sharing knowledge and learning from peers.
                </p>
              </div>

              <div class="text-center">
                <div class="w-16 h-16 bg-primary-100 dark:bg-primary-900 rounded-full flex items-center justify-center mx-auto mb-4">
                  <.icon name="hero-light-bulb" class="w-8 h-8 text-primary-600 dark:text-primary-400" />
                </div>
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">Innovation</h3>
                <p class="text-gray-600 dark:text-gray-300 text-sm">
                  Always looking for innovative solutions and better ways to solve complex problems.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Contact Section -->
      <section id="contact" class="py-20 px-4 sm:px-6 lg:px-8 bg-white dark:bg-gray-800">
        <div class="max-w-4xl mx-auto">
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
                <div class="flex items-center space-x-4 p-4 bg-gray-50 dark:bg-gray-900 rounded-lg shadow-md hover:shadow-lg transition-shadow">
                  <div class="w-12 h-12 bg-primary-100 dark:bg-primary-900 rounded-lg flex items-center justify-center">
                    <.icon name="hero-envelope" class="w-6 h-6 text-primary-600 dark:text-primary-400" />
                  </div>
                  <div>
                    <h3 class="font-semibold text-gray-900 dark:text-white">Email</h3>
                    <a href="mailto:stephen@stephenszpak.dev" class="text-primary-600 dark:text-primary-400 hover:underline">
                      stephen@stephenszpak.dev
                    </a>
                  </div>
                </div>

                <div class="flex items-center space-x-4 p-4 bg-gray-50 dark:bg-gray-900 rounded-lg shadow-md hover:shadow-lg transition-shadow">
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

                <div class="flex items-center space-x-4 p-4 bg-gray-50 dark:bg-gray-900 rounded-lg shadow-md hover:shadow-lg transition-shadow">
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
                <div class="bg-gray-50 dark:bg-gray-900 rounded-2xl shadow-xl p-8 text-center">
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
                <div class="bg-gray-50 dark:bg-gray-900 rounded-2xl shadow-xl p-8">
                  <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-6">
                    Send Me a Message
                  </h2>

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
          <div class="mt-20 bg-gray-50 dark:bg-gray-900 rounded-2xl shadow-xl p-8">
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
      </section>

      <!-- Sticky AI Assistant Button -->
      <%= if @api_key_configured do %>
        <div class="fixed bottom-6 right-6 z-50">
          <button
            phx-click="toggle_assistant"
            class="w-14 h-14 bg-primary-600 hover:bg-primary-700 text-white rounded-full shadow-xl hover:shadow-2xl transition-all duration-200 flex items-center justify-center group"
            title="AI Assistant"
          >
            <%= if @assistant_open do %>
              <.icon name="hero-x-mark" class="w-6 h-6" />
            <% else %>
              <.icon name="hero-chat-bubble-left-ellipsis" class="w-6 h-6 group-hover:scale-110 transition-transform" />
            <% end %>
          </button>
        </div>
      <% end %>

      <!-- AI Assistant Modal -->
      <%= if @assistant_open do %>
        <div class="fixed inset-0 bg-black bg-opacity-50 flex items-end justify-end p-4 z-50 animate-fade-in">
          <div class="bg-white dark:bg-gray-800 rounded-t-2xl w-full max-w-md h-[60vh] flex flex-col shadow-2xl animate-slide-up">
            <!-- Chat Header -->
            <div class="bg-primary-600 dark:bg-primary-700 px-6 py-4 flex items-center justify-between rounded-t-2xl">
              <div class="flex items-center space-x-3">
                <div class="w-8 h-8 bg-white bg-opacity-20 rounded-full flex items-center justify-center">
                  <.icon name="hero-chat-bubble-left-ellipsis" class="w-5 h-5 text-white" />
                </div>
                <div>
                  <h3 class="text-white font-semibold">Stephen's AI Assistant</h3>
                  <p class="text-primary-100 text-sm">Ask me anything about Stephen's work!</p>
                </div>
              </div>
              
              <div class="flex items-center space-x-2">
                <%= if length(@messages) > 0 do %>
                  <button
                    phx-click="clear_chat"
                    class="text-primary-100 hover:text-white transition-colors p-1"
                    title="Clear chat"
                  >
                    <.icon name="hero-trash" class="w-4 h-4" />
                  </button>
                <% end %>
                <button
                  phx-click="close_assistant"
                  class="text-primary-100 hover:text-white transition-colors p-1"
                  title="Close"
                >
                  <.icon name="hero-x-mark" class="w-5 h-5" />
                </button>
              </div>
            </div>

            <!-- Messages -->
            <div class="flex-1 overflow-y-auto p-4 space-y-4" id="chat-messages">
              <%= if length(@messages) == 0 do %>
                <div class="text-center text-gray-500 dark:text-gray-400 py-8">
                  <.icon name="hero-chat-bubble-oval-left-ellipsis" class="w-12 h-12 mx-auto mb-4 opacity-50" />
                  <p class="text-sm">Start a conversation! Ask me about Stephen's projects, experience, or technologies.</p>
                  <div class="mt-4 space-y-2">
                    <p class="text-xs font-medium">Try asking:</p>
                    <div class="space-y-1">
                      <div class="text-xs bg-gray-100 dark:bg-gray-700 px-2 py-1 rounded mx-auto inline-block">
                        "What projects has Stephen worked on?"
                      </div>
                      <div class="text-xs bg-gray-100 dark:bg-gray-700 px-2 py-1 rounded mx-auto inline-block">
                        "What technologies does he use?"
                      </div>
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
                      "max-w-xs px-3 py-2 rounded-2xl text-sm",
                      message.type == :user && "bg-primary-600 text-white",
                      message.type == :assistant && "bg-gray-100 dark:bg-gray-700 text-gray-900 dark:text-white"
                    ]}> 
                      <%= if Map.get(message, :streaming, false) && message.content == "" do %>
                        <div class="flex items-center space-x-2">
                          <div class="animate-spin rounded-full h-3 w-3 border-b-2 border-primary-600"></div>
                          <p class="text-xs text-gray-500 dark:text-gray-400">Thinking...</p>
                        </div>
                      <% else %>
                        <p class="whitespace-pre-wrap"><%= message.content %></p>
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
              <form phx-submit="send_message_ai" class="flex space-x-2">
                <input
                  type="text"
                  name="message"
                  value={@current_message}
                  phx-change="update_message"
                  placeholder={if @loading, do: "AI is thinking...", else: "Ask me about Stephen's work..."}
                  disabled={@loading}
                  class={[
                    "flex-1 px-3 py-2 text-sm border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 dark:bg-gray-700 dark:text-white transition-opacity",
                    @loading && "opacity-50 cursor-not-allowed"
                  ]}
                  autocomplete="off"
                />
                <button
                  type="submit"
                  disabled={String.trim(@current_message) == "" || @loading}
                  class={[
                    "px-3 py-2 rounded-lg transition-colors text-sm",
                    (@loading || String.trim(@current_message) == "") && "bg-gray-300 dark:bg-gray-600 cursor-not-allowed",
                    (!@loading && String.trim(@current_message) != "") && "bg-primary-600 hover:bg-primary-700 text-white"
                  ]}
                >
                  <%= if @loading do %>
                    <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                  <% else %>
                    <.icon name="hero-paper-airplane" class="w-4 h-4" />
                  <% end %>
                </button>
              </form>
            </div>
          </div>
        </div>
      <% end %>

      <!-- Project Modal -->
      <%= if @selected_project do %>
        <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50 animate-fade-in" phx-click="close_modal">
          <div class="bg-white dark:bg-gray-800 rounded-2xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
            <!-- Modal Header -->
            <div class="flex items-center justify-between p-6 border-b border-gray-200 dark:border-gray-700">
              <h2 class="text-2xl font-bold text-gray-900 dark:text-white">
                <%= @selected_project.title %>
              </h2>
              <button phx-click="close_modal" class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300">
                <.icon name="hero-x-mark" class="w-6 h-6" />
              </button>
            </div>

            <!-- Modal Content -->
            <div class="p-6">
              <!-- Project Image Placeholder -->
              <div class="h-64 bg-gradient-to-br from-primary-400 to-purple-500 rounded-xl mb-6 flex items-center justify-center">
                <.icon name="hero-photo" class="w-24 h-24 text-white opacity-60" />
              </div>

              <!-- Description -->
              <div class="mb-6">
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">About This Project</h3>
                <p class="text-gray-600 dark:text-gray-300 leading-relaxed">
                  <%= @selected_project.long_description %>
                </p>
              </div>

              <!-- Technologies -->
              <div class="mb-6">
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">Technologies Used</h3>
                <div class="flex flex-wrap gap-2">
                  <%= for tech <- @selected_project.technologies do %>
                    <span class="bg-primary-50 dark:bg-primary-900/30 text-primary-700 dark:text-primary-300 px-3 py-1 rounded-full text-sm font-medium">
                      <%= tech %>
                    </span>
                  <% end %>
                </div>
              </div>

              <!-- Actions -->
              <div class="flex flex-col sm:flex-row gap-4">
                <%= if @selected_project.github_url do %>
                  <a href={@selected_project.github_url} target="_blank" class="inline-flex items-center justify-center px-6 py-3 bg-gray-900 dark:bg-gray-700 text-white rounded-lg hover:bg-gray-800 dark:hover:bg-gray-600 transition-colors">
                    <.icon name="hero-code-bracket" class="w-5 h-5 mr-2" />
                    View Source Code
                  </a>
                <% end %>
                <%= if @selected_project.live_url do %>
                  <a href={@selected_project.live_url} target="_blank" class="inline-flex items-center justify-center px-6 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors">
                    <.icon name="hero-arrow-top-right-on-square" class="w-5 h-5 mr-2" />
                    View Live Demo
                  </a>
                <% end %>
              </div>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end