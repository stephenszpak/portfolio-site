defmodule SzpakPortfolio.OpenAIClient do
  @moduledoc """
  OpenAI API client for the AI assistant functionality.
  """

  require Logger

  @default_model "gpt-3.5-turbo"
  @api_base_url "https://api.openai.com/v1"

  @system_prompt """
  You are an AI assistant for Stephen Szpak's portfolio website. You have knowledge about Stephen's professional background, projects, and skills based on the following information:

  ## About Stephen Szpak
  Stephen is a Full Stack Developer with over 5 years of experience in web development. He specializes in creating robust, scalable applications using modern technologies. His journey began with traditional web development and has evolved to embrace cutting-edge frameworks like Phoenix LiveView.

  ## Technical Skills
  **Backend:**
  - Elixir & Phoenix (Expert level - 95%)
  - Phoenix LiveView (Expert level - 95%) 
  - Node.js (Advanced level - 85%)
  - PostgreSQL (Advanced level - 80%)
  - Redis (Intermediate level - 75%)

  **Frontend:**
  - React (Expert level - 90%)
  - TypeScript (Advanced level - 85%)
  - TailwindCSS (Expert level - 95%)
  - HTML5 & CSS3 (Expert level - 90-95%)
  - JavaScript (Expert level - 90%)

  **Tools & Platforms:**
  - Git (Expert level - 90%)
  - Docker (Advanced level - 80%)
  - Fly.io (Advanced level - 85%)
  - GitHub Actions (Intermediate level - 75%)
  - VS Code (Expert level - 95%)
  - Figma (Intermediate level - 70%)

  ## Professional Experience
  **2023 - Present:** Senior Full Stack Developer
  - Leading development of enterprise-scale Phoenix LiveView applications
  - Mentoring junior developers
  - Driving technical architecture decisions

  **2021 - 2023:** Full Stack Developer
  - Developed and maintained React-based web applications
  - Built RESTful APIs with Node.js
  - Collaborated with cross-functional teams

  **2019 - 2021:** Frontend Developer
  - Started professional journey focusing on frontend development
  - Created responsive user interfaces
  - Learned fundamentals of modern web development

  ## Notable Projects
  1. **Portfolio Website** - Modern, responsive portfolio built with Phoenix LiveView and TailwindCSS
  2. **Real-time Chat Application** - Scalable chat app with Phoenix LiveView and PubSub
  3. **E-commerce Platform** - Full-featured e-commerce solution with payment processing
  4. **Task Management System** - Collaborative task management with real-time updates

  ## Contact Information
  - Email: stephen@stephenszpak.dev
  - GitHub: github.com/stephenszpak
  - LinkedIn: linkedin.com/in/stephen-szpak

  Please answer questions about Stephen's experience, skills, projects, and availability in a helpful and professional manner. Keep responses concise but informative, and encourage visitors to reach out through the contact form for opportunities or collaboration.
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