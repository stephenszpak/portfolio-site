defmodule SzpakPortfolioWeb.ProjectsLive do
  use SzpakPortfolioWeb, :live_view

  def mount(_params, _session, socket) do
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
        title: "Real-time Chat Application",
        description: "A scalable chat application with real-time messaging, user presence, and file sharing.",
        long_description: "Built with Phoenix LiveView and PubSub, this chat application supports real-time messaging, user presence indicators, file uploads, and message history. The application can handle thousands of concurrent users with Phoenix's excellent concurrency model.",
        image: "/images/projects/chat-app.jpg",
        technologies: ["Phoenix LiveView", "Elixir", "PostgreSQL", "Phoenix PubSub"],
        github_url: "https://github.com/stephenszpak/liveview-chat",
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
        title: "Task Management System",
        description: "Collaborative task management with real-time updates and team collaboration features.",
        long_description: "A modern task management system inspired by tools like Trello and Asana. Features include drag-and-drop task boards, real-time collaboration, file attachments, and team management.",
        image: "/images/projects/task-manager.jpg",
        technologies: ["React", "TypeScript", "Node.js", "MongoDB"],
        github_url: "https://github.com/stephenszpak/task-manager",
        live_url: nil,
        status: "completed"
      }
    ]

    {:ok, assign(socket, page_title: "Projects - Stephen Szpak", projects: projects, selected_project: nil)}
  end

  def handle_event("open_modal", %{"project_id" => project_id}, socket) do
    project = Enum.find(socket.assigns.projects, &(&1.id == String.to_integer(project_id)))
    {:noreply, assign(socket, selected_project: project)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, selected_project: nil)}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 dark:bg-gray-900 py-20">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
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
              "bg-white dark:bg-gray-800 rounded-2xl shadow-lg hover:shadow-2xl transition-all duration-300 overflow-hidden group cursor-pointer animate-slide-up",
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