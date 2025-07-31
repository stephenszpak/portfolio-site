defmodule SzpakPortfolioWeb.TechnologiesLive do
  use SzpakPortfolioWeb, :live_view

  def mount(_params, _session, socket) do
    technologies = %{
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

    {:ok, assign(socket, page_title: "Technologies - Stephen Szpak", technologies: technologies, selected_category: :backend)}
  end

  def handle_event("select_category", %{"category" => category}, socket) do
    {:noreply, assign(socket, selected_category: String.to_atom(category))}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 dark:bg-gray-900 py-20">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
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
    </div>
    """
  end
end