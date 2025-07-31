defmodule SzpakPortfolioWeb.HomeLive do
  use SzpakPortfolioWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Stephen Szpak - Full Stack Developer")}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 dark:bg-gray-900">
      <!-- Hero Section -->
      <section class="relative min-h-screen flex items-center justify-center px-4 sm:px-6 lg:px-8">
        <div class="absolute inset-0 overflow-hidden">
          <div class="absolute -top-40 -right-40 w-80 h-80 bg-primary-200 dark:bg-primary-800 rounded-full mix-blend-multiply dark:mix-blend-normal filter blur-xl opacity-70 animate-float"></div>
          <div class="absolute -bottom-40 -left-40 w-80 h-80 bg-purple-200 dark:bg-purple-800 rounded-full mix-blend-multiply dark:mix-blend-normal filter blur-xl opacity-70 animate-float" style="animation-delay: 2s;"></div>
        </div>

        <div class="relative text-center animate-fade-in">
          <h1 class="text-5xl sm:text-6xl lg:text-7xl font-bold font-display mb-6">
            <span class="text-gray-900 dark:text-white">Stephen</span>
            <span class="text-gradient">Szpak</span>
          </h1>
          
          <p class="text-xl sm:text-2xl text-gray-600 dark:text-gray-300 mb-8 max-w-3xl mx-auto">
            Full Stack Developer crafting modern web applications with 
            <span class="text-primary-600 dark:text-primary-400 font-semibold">Phoenix LiveView</span>, 
            <span class="text-primary-600 dark:text-primary-400 font-semibold">React</span>, and 
            <span class="text-primary-600 dark:text-primary-400 font-semibold">Node.js</span>
          </p>

          <div class="flex flex-col sm:flex-row gap-4 justify-center items-center mb-12">
            <.link navigate="/projects" class="inline-flex items-center px-8 py-4 bg-primary-600 hover:bg-primary-700 text-white font-semibold rounded-lg transition-colors duration-200 shadow-lg hover:shadow-xl">
              <.icon name="hero-rocket-launch" class="w-5 h-5 mr-2" />
              View My Work
            </.link>
            
            <.link navigate="/contact" class="inline-flex items-center px-8 py-4 border-2 border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 hover:border-primary-500 hover:text-primary-600 dark:hover:text-primary-400 font-semibold rounded-lg transition-colors duration-200">
              <.icon name="hero-chat-bubble-left-ellipsis" class="w-5 h-5 mr-2" />
              Get In Touch
            </.link>
          </div>

          <div class="flex justify-center space-x-6">
            <a href="https://github.com/stephenszpak" target="_blank" class="text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors duration-200">
              <.icon name="hero-code-bracket" class="w-6 h-6" />
            </a>
            <a href="https://linkedin.com/in/stephen-szpak" target="_blank" class="text-gray-600 dark:text-gray-400 hover:text-primary-600 dark:hover:text-primary-400 transition-colors duration-200">
              <.icon name="hero-user-group" class="w-6 h-6" />
            </a>
          </div>
        </div>

        <!-- Scroll indicator -->
        <div class="absolute bottom-8 left-1/2 transform -translate-x-1/2 animate-bounce">
          <.icon name="hero-chevron-down" class="w-6 h-6 text-gray-400" />
        </div>
      </section>

      <!-- Quick Overview Section -->
      <section class="py-20 px-4 sm:px-6 lg:px-8">
        <div class="max-w-6xl mx-auto">
          <div class="grid md:grid-cols-3 gap-8">
            <div class="text-center p-6 rounded-xl bg-white dark:bg-gray-800 shadow-lg hover:shadow-xl transition-shadow duration-300 animate-slide-up">
              <div class="w-12 h-12 bg-primary-100 dark:bg-primary-900 rounded-lg flex items-center justify-center mx-auto mb-4">
                <.icon name="hero-code-bracket-square" class="w-6 h-6 text-primary-600 dark:text-primary-400" />
              </div>
              <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">Full Stack Development</h3>
              <p class="text-gray-600 dark:text-gray-300">Building end-to-end web applications with modern technologies and best practices.</p>
            </div>

            <div class="text-center p-6 rounded-xl bg-white dark:bg-gray-800 shadow-lg hover:shadow-xl transition-shadow duration-300 animate-slide-up" style="animation-delay: 0.1s;">
              <div class="w-12 h-12 bg-primary-100 dark:bg-primary-900 rounded-lg flex items-center justify-center mx-auto mb-4">
                <.icon name="hero-lightning-bolt" class="w-6 h-6 text-primary-600 dark:text-primary-400" />
              </div>
              <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">LiveView Expertise</h3>
              <p class="text-gray-600 dark:text-gray-300">Creating interactive, real-time web applications using Phoenix LiveView.</p>
            </div>

            <div class="text-center p-6 rounded-xl bg-white dark:bg-gray-800 shadow-lg hover:shadow-xl transition-shadow duration-300 animate-slide-up" style="animation-delay: 0.2s;">
              <div class="w-12 h-12 bg-primary-100 dark:bg-primary-900 rounded-lg flex items-center justify-center mx-auto mb-4">
                <.icon name="hero-device-phone-mobile" class="w-6 h-6 text-primary-600 dark:text-primary-400" />
              </div>
              <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-2">Responsive Design</h3>
              <p class="text-gray-600 dark:text-gray-300">Crafting beautiful, mobile-first interfaces that work seamlessly across all devices.</p>
            </div>
          </div>
        </div>
      </section>
    </div>
    """
  end
end