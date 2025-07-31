# Stephen Szpak's Portfolio

A modern, responsive portfolio website built with Phoenix LiveView and TailwindCSS, showcasing professional experience, projects, and skills.

## 🚀 Features

- **Modern Design**: Clean, responsive layout with dark/light mode support
- **Phoenix LiveView**: Real-time interactivity without JavaScript complexity  
- **TailwindCSS**: Utility-first CSS framework with custom design system
- **Mobile-First**: Responsive design that works seamlessly across all devices
- **SEO Optimized**: Proper meta tags and semantic HTML structure
- **AI Assistant**: Placeholder integration for OpenAI-powered chat (optional)
- **Contact Form**: LiveView-powered contact form with validation
- **Project Showcase**: Interactive project cards with modal details
- **Technology Stack**: Categorized display of technical skills
- **Smooth Animations**: CSS transitions and animations for better UX

## 🛠 Tech Stack

- **Backend**: Elixir 1.16+, Phoenix 1.7+, Phoenix LiveView
- **Frontend**: TailwindCSS, AlpineJS (for dark mode), Heroicons
- **Database**: PostgreSQL (for development/production)
- **Deployment**: Fly.io ready with Docker configuration
- **Fonts**: Inter & Titillium Web from Google Fonts

## 🏗 Project Structure

```
lib/szpak_portfolio_web/live/
├── home_live.ex           # Homepage with hero section
├── about_live.ex          # About page with bio/timeline toggle
├── projects_live.ex       # Projects showcase with modals
├── technologies_live.ex   # Technical skills categorized
├── contact_live.ex        # Contact form with validation
└── assistant_live.ex      # AI assistant placeholder

lib/szpak_portfolio_web/components/layouts/
├── root.html.heex         # Root layout with dark mode setup
└── app.html.heex          # Navigation and main layout

assets/
├── css/app.css           # Custom styles and utilities
├── js/app.js             # Phoenix LiveView JavaScript
└── tailwind.config.js    # TailwindCSS configuration
```

## 🚦 Getting Started

### Prerequisites

#### For Docker Development (Recommended)
- Docker and Docker Compose
- Git

#### For Native Development
- Elixir 1.16 or later
- Erlang/OTP 26 or later  
- Node.js 18+ (for asset compilation)
- PostgreSQL 13+ (for database)

### Local Development

#### Option 1: Docker Development (Recommended)

1. **Clone and navigate to the project:**
   ```bash
   git clone <repository-url>
   cd szpak_portfolio
   ```

2. **Start with Docker Compose:**
   ```bash
   docker-compose up --build
   ```

3. **Visit the application:**
   Open [`localhost:4000`](http://localhost:4000) in your browser.

The Docker setup includes:
- PostgreSQL database (port 5432)
- Phoenix application with hot reloading
- Automatic database creation and migrations

#### Option 2: Native Development

1. **Clone and navigate to the project:**
   ```bash
   git clone <repository-url>
   cd szpak_portfolio
   ```

2. **Install dependencies:**
   ```bash
   mix deps.get
   cd assets && npm install && cd ..
   ```

3. **Set up environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Create and migrate database:**
   ```bash
   mix ecto.create
   mix ecto.migrate
   ```

5. **Start the Phoenix server:**
   ```bash
   mix phx.server
   ```

6. **Visit the application:**
   Open [`localhost:4000`](http://localhost:4000) in your browser.

### Development with IEx

For interactive development with IEx console:

```bash
iex -S mix phx.server
```

## 🎨 Customization

### Updating Content

- **Personal Information**: Edit the LiveView modules in `lib/szpak_portfolio_web/live/`
- **Projects**: Update the projects list in `projects_live.ex`
- **Technologies**: Modify the technologies map in `technologies_live.ex`
- **About Content**: Update bio and timeline in `about_live.ex`

### Styling

- **Colors**: Modify the color palette in `assets/tailwind.config.js`
- **Fonts**: Update font configuration in `tailwind.config.js` and `app.css`
- **Custom Styles**: Add utility classes in `assets/css/app.css`

### AI Assistant

To enable the AI assistant feature:

1. Sign up for OpenAI API access
2. Add your API key to environment variables:
   ```bash
   OPENAI_API_KEY=your_api_key_here
   ```
3. Implement the OpenAI integration in `assistant_live.ex`

## 🚀 Deployment

### Docker Container Deployment

The application is containerized and can be deployed to any Docker-compatible platform:

#### Building Production Container

```bash
# Build the production image
docker build -t szpak-portfolio .

# Run the container
docker run -p 4000:8080 \
  -e DATABASE_URL=your_database_url \
  -e SECRET_KEY_BASE=your_secret_key \
  -e PHX_HOST=your-domain.com \
  szpak-portfolio
```

### Fly.io Deployment (Recommended)

This project includes automated Fly.io deployment scripts:

#### Initial Setup

1. **Install Fly.io CLI:**
   ```bash
   curl -L https://fly.io/install.sh | sh
   ```

2. **Login to Fly.io:**
   ```bash
   fly auth login
   ```

3. **Run the setup script:**
   ```bash
   ./scripts/setup-fly.sh
   ```

This will:
- Create your Fly.io application
- Set up a PostgreSQL database
- Configure the database connection

#### Deploying Updates

```bash
./scripts/deploy.sh
```

#### Manual Deployment

If you prefer manual control:

```bash
# Launch the app (first time only)
fly launch

# Create PostgreSQL database
fly postgres create --name szpak-portfolio-db

# Attach database to your app
fly postgres attach szpak-portfolio-db

# Deploy
fly deploy
```

#### Setting Up Custom Domain

After deployment, configure your custom domain:

```bash
# Add your custom domain
fly certs create your-domain.com

# Add www subdomain (optional)
fly certs create www.your-domain.com
```

Then configure your DNS:
- Create an A record: `your-domain.com` → Fly.io IP address
- Create a CNAME record: `www.your-domain.com` → `your-domain.com`

### Other Deployment Options

The Docker container can be deployed to any platform that supports containers:

- **Digital Ocean**: App Platform with Docker
- **AWS**: ECS, Fargate, or Elastic Beanstalk
- **Google Cloud**: Cloud Run or GKE
- **Azure**: Container Instances or AKS
- **Heroku**: Container Registry
- **Railway**: Docker deployments

## 🐳 Docker Commands

### Development Commands

```bash
# Start development environment
docker-compose up

# Rebuild and start
docker-compose up --build

# Run in background
docker-compose up -d

# View logs
docker-compose logs -f web

# Stop services
docker-compose down

# Reset everything (including database)
docker-compose down -v
```

### Production Commands

```bash
# Build production image
docker build -t szpak-portfolio .

# Tag for registry
docker tag szpak-portfolio your-registry/szpak-portfolio:latest

# Push to registry
docker push your-registry/szpak-portfolio:latest

# Run production container
docker run -d \
  --name szpak-portfolio \
  -p 4000:8080 \
  -e DATABASE_URL=your_database_url \
  -e SECRET_KEY_BASE=your_secret_key \
  -e PHX_HOST=your-domain.com \
  szpak-portfolio
```

### Database Commands

```bash
# Run migrations in container
docker-compose exec web mix ecto.migrate

# Create database
docker-compose exec web mix ecto.create

# Drop and recreate database
docker-compose exec web mix ecto.reset

# Access database directly
docker-compose exec db psql -U postgres -d szpak_portfolio_dev
```

## 📱 Routes

- `/` - Homepage with hero section
- `/about` - About page with bio and timeline
- `/projects` - Project showcase with interactive modals
- `/technologies` - Technical skills and experience
- `/contact` - Contact form with validation
- `/assistant` - AI assistant chat interface (optional)
- `/health` - Health check endpoint for monitoring

## 🔧 Configuration

### Environment Variables

Create a `.env` file based on `.env.example`:

```bash
# Required
DATABASE_URL=ecto://postgres:postgres@localhost/szpak_portfolio_dev
SECRET_KEY_BASE=your_secret_key_base

# Optional Features  
OPENAI_API_KEY=your_openai_api_key        # For AI assistant
SMTP_HOST=smtp.gmail.com                  # For contact emails
SMTP_USERNAME=your_email@gmail.com
SMTP_PASSWORD=your_app_password
CONTACT_EMAIL=stephen@example.com
GOOGLE_ANALYTICS_ID=G-XXXXXXXXXX         # For analytics
```

### Phoenix Configuration

Key configuration files:
- `config/dev.exs` - Development configuration
- `config/prod.exs` - Production configuration  
- `config/runtime.exs` - Runtime configuration

## 🧪 Testing

Run the test suite:

```bash
mix test
```

For test coverage:

```bash
mix test --cover
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`mix test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

If you have questions or need help:

1. Check the [Phoenix documentation](https://hexdocs.pm/phoenix)  
2. Visit the [Elixir Forum](https://elixirforum.com/c/phoenix-forum)
3. Open an issue in this repository

## 🙏 Acknowledgments

- [Phoenix Framework](https://phoenixframework.org/) - The productive web framework
- [TailwindCSS](https://tailwindcss.com/) - Utility-first CSS framework
- [Heroicons](https://heroicons.com/) - Beautiful hand-crafted SVG icons
- [Fly.io](https://fly.io/) - Application deployment platform
