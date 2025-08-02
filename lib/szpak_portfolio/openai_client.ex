defmodule SzpakPortfolio.OpenAIClient do
  @moduledoc """
  OpenAI API client for the AI assistant functionality.
  """

  require Logger

  @default_model "gpt-3.5-turbo"
  @api_base_url "https://api.openai.com/v1"

  @system_prompt """
  You are an AI assistant for Stephen Szpak's portfolio website. You are knowledgeable, professional, and enthusiastic about Stephen's AI-focused development work. Answer questions about his experience, skills, projects, and availability.

  ## About Stephen Szpak
  Stephen is an AI-Focused Full Stack Developer with over 9 years of experience in web development. Currently serving as AVP Front-End Developer at AllianceBernstein, he specializes in building modern, performant front-end systems and experimenting with AI integration. 

  Outside of his core role, he independently designs and builds AI-powered applications and internal prototypes using Phoenix LiveView, OpenAI APIs, and modern Elixir-based architectures.

  ## Current Role (2022 - Present)
  **AVP / Front-End Developer at AllianceBernstein**
  - Architected reusable component-based design system with Azure build pipelines, NPM package releases, SCSS, and clean JS
  - Collaborated in cross-functional meetings with UX, Design, QA, and IT teams
  - Assisted offshore team in creation of new AEM components using Java
  - Spearheaded integration of multiple European country segments into alliancebernstein.com
  - Prototyped internal AI tools for marketing analytics and dashboard automation

  ## Previous Experience
  **Software Developer at Ingram Content Group (2017-2022)**
  - Led upgrade from AngularJS to Angular 11, and authored React migration PoC
  - Built multi-database syncing tools (Mainframe → MySQL/Vertica)
  - Created $1.2M-generating wholesale reporting dashboard using R
  - Developed high-performance financial reporting app (C#)
  - Mentored developers across Ruby on Rails and Angular

  ## AI & Technical Skills
  **AI/ML (Primary Focus):**
  - OpenAI API (95%) - GPT-4, ChatGPT, and DALL-E integrations
  - Anthropic API (90%) - Advanced reasoning and code generation
  - LLM Integration (90%) - Conversational AI and intelligent workflows
  - AI Workflows (85%) - AI-powered business processes
  - Prompt Engineering (90%) - Optimizing AI responses and reliability
  - Vector Databases (75%) - Embeddings and semantic search

  **Backend:**
  - Elixir (90%), Phoenix (95%), Phoenix LiveView (95%)
  - Node.js (85%), Ruby on Rails (85%), C# (85%)
  - PostgreSQL (80%), Redis (75%), Rust (50% - currently learning)

  **Frontend:**
  - React (90%), TypeScript (85%), TailwindCSS (95%)
  - HTML5 (95%), CSS3 (90%), JavaScript (90%)

  **Tools:**
  - Git (90%), Docker (80%), VIM (95%)
  - Azure DevOps (90%), AEM (85%), Kubernetes (70%)
  - Fly.io (85%), GitHub Actions (75%), AdobeXD (80%)

  ## Notable Projects
  1. **Portfolio Website** - Modern Phoenix LiveView portfolio with AI assistant integration
  2. **MMO-Server** - Experimental multiplayer game server with distributed player management, real-time gameplay, NPC AI systems, and comprehensive combat engine
  3. **DevTeam AI** - AI-powered development team simulation with collaborative intelligent agents for automated code generation using Phoenix LiveView, React, Python, and AutoGen framework
  4. **NL-Dashboard** - AI-powered analytics dashboard with natural language processing, sentiment analysis, and conversational AI interface

  ## Contact & Links
  - Email: stephen@stephenszpak.com
  - GitHub: github.com/stephenszpak
  - LinkedIn: linkedin.com/in/stephen-szpak
  - Portfolio: https://stephenszpak.dev

  ## Response Guidelines
  - Be enthusiastic about Stephen's AI expertise and innovative projects
  - Highlight his unique combination of enterprise experience and AI experimentation
  - Mention specific technologies and achievements when relevant
  - Encourage visitors to explore his projects or reach out for collaboration
  - Keep responses conversational but professional
  - If asked about availability, mention he's open to discussing interesting AI projects and consulting opportunities
  """

  @doc """
  Sends a chat completion request to OpenAI API.
  """
  def chat_completion(messages, opts \\ []) do
    api_key = get_api_key()
    
    if api_key do
      model = Keyword.get(opts, :model, @default_model)
      stream = Keyword.get(opts, :stream, false)
      
      body = %{
        model: model,
        messages: [%{role: "system", content: @system_prompt} | messages],
        stream: stream,
        max_tokens: 500,
        temperature: 0.7
      }

      headers = [
        {"authorization", "Bearer #{api_key}"},
        {"content-type", "application/json"}
      ]

      case Req.post("#{@api_base_url}/chat/completions", json: body, headers: headers) do
        {:ok, %{status: 200, body: response}} ->
          {:ok, response}
        
        {:ok, %{status: status, body: body}} ->
          Logger.error("OpenAI API error: #{status} - #{inspect(body)}")
          {:error, "API request failed with status #{status}"}
        
        {:error, reason} ->
          Logger.error("OpenAI API request failed: #{inspect(reason)}")
          {:error, "Failed to connect to OpenAI API"}
      end
    else
      {:error, "OpenAI API key not configured"}
    end
  end

  @doc """
  Sends a streaming chat completion request to OpenAI API.
  Returns a stream of Server-Sent Events.
  """
  def chat_completion_stream(messages, callback, opts \\ []) do
    api_key = get_api_key()
    
    if api_key do
      model = Keyword.get(opts, :model, @default_model)
      
      body = %{
        model: model,
        messages: [%{role: "system", content: @system_prompt} | messages],
        stream: true,
        max_tokens: 500,
        temperature: 0.7
      }

      headers = [
        {"authorization", "Bearer #{api_key}"},
        {"content-type", "application/json"}
      ]

      try do
        Req.post!("#{@api_base_url}/chat/completions", 
          json: body, 
          headers: headers,
          into: fn {:data, data}, {req, resp} ->
            # Parse Server-Sent Events
            process_sse_chunk(data, callback)
            {:cont, {req, resp}}
          end
        )
        {:ok, "Stream completed"}
      rescue
        e ->
          Logger.error("OpenAI streaming error: #{inspect(e)}")
          {:error, "Streaming request failed"}
      end
    else
      {:error, "OpenAI API key not configured"}
    end
  end

  @doc """
  Checks if OpenAI API key is configured.
  """
  def api_key_configured? do
    case get_api_key() do
      nil -> false
      "" -> false
      _key -> true
    end
  end

  # Private functions

  defp get_api_key do
    System.get_env("OPENAI_API_KEY")
  end

  defp process_sse_chunk(data, callback) do
    # Split by lines and process each Server-Sent Event
    data
    |> String.split("\n")
    |> Enum.each(fn line ->
      cond do
        String.starts_with?(line, "data: ") ->
          data_content = String.trim_leading(line, "data: ")
          
          case data_content do
            "[DONE]" ->
              callback.({:done, nil})
            
            "" ->
              :ok
            
            json_data ->
              case Jason.decode(json_data) do
                {:ok, %{"choices" => [%{"delta" => delta} | _]}} ->
                  if content = delta["content"] do
                    callback.({:content, content})
                  end
                
                {:ok, _} ->
                  :ok
                
                {:error, _} ->
                  :ok
              end
          end
        
        String.starts_with?(line, "event: ") ->
          :ok
        
        line == "" ->
          :ok
        
        true ->
          :ok
      end
    end)
  end
end
