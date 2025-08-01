// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken}
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Dark mode functionality
document.addEventListener("DOMContentLoaded", function() {
  // Initialize dark mode - default to dark mode
  const darkMode = localStorage.getItem('darkMode') !== 'false';
  
  if (darkMode) {
    document.documentElement.classList.add('dark');
  }

  // Handle dark mode toggle clicks
  document.addEventListener('click', function(e) {
    if (e.target.closest('[data-toggle-dark-mode]')) {
      const isDark = document.documentElement.classList.contains('dark');
      
      if (isDark) {
        document.documentElement.classList.remove('dark');
        localStorage.setItem('darkMode', 'false');
      } else {
        document.documentElement.classList.add('dark');
        localStorage.setItem('darkMode', 'true');
      }
    }
    
    // Handle mobile menu toggle
    if (e.target.closest('[data-toggle-mobile-menu]')) {
      const mobileMenu = document.querySelector('.mobile-menu');
      const menuOpenIcon = document.querySelector('.mobile-menu-open');
      const menuClosedIcon = document.querySelector('.mobile-menu-closed');
      
      if (mobileMenu.classList.contains('hidden')) {
        mobileMenu.classList.remove('hidden');
        menuOpenIcon.classList.remove('hidden');
        menuClosedIcon.classList.add('hidden');
      } else {
        mobileMenu.classList.add('hidden');
        menuOpenIcon.classList.add('hidden');
        menuClosedIcon.classList.remove('hidden');
      }
    }
  });
});

