defmodule SzpakPortfolioWeb.AboutLive do
  use SzpakPortfolioWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "About - Stephen Szpak", view_mode: "bio")}
  end

  def handle_event("toggle_view", %{"mode" => mode}, socket) do
    {:noreply, assign(socket, view_mode: mode)}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 dark:bg-gray-900 py-20">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
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

        <!-- Content -->
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
    </div>
    """
  end
end