defmodule SzpakPortfolio.SpamProtection do
  @moduledoc """
  Spam protection utilities for the contact form.
  Includes rate limiting, honeypot detection, and basic content filtering.
  """

  @rate_limit_window 60 * 60 * 1000  # 1 hour in milliseconds
  @max_submissions_per_hour 3
  @min_form_fill_time 3000  # 3 seconds minimum to fill form
  @max_form_fill_time 30 * 60 * 1000  # 30 minutes maximum

  @doc """
  Validates a contact form submission for spam indicators.
  Returns :ok if the submission passes all checks, or {:error, reason} if it fails.
  """
  def validate_submission(params, metadata \\ %{}) do
    with :ok <- check_required_fields(params),
         :ok <- check_honeypot(params),
         :ok <- check_content_quality(params),
         :ok <- check_rate_limit(metadata),
         :ok <- check_form_timing(metadata) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  # Check that all required fields are present and not empty
  defp check_required_fields(params) do
    required_fields = ["name", "email", "subject", "message"]
    
    missing_fields = 
      required_fields
      |> Enum.filter(fn field -> 
        not Map.has_key?(params, field) or String.trim(params[field] || "") == ""
      end)
    
    if Enum.empty?(missing_fields) do
      :ok
    else
      {:error, "Missing required fields: #{Enum.join(missing_fields, ", ")}"}
    end
  end

  # Check honeypot field (should be empty)
  defp check_honeypot(params) do
    case Map.get(params, "website", "") do
      "" -> :ok
      _ -> {:error, "Bot detected via honeypot"}
    end
  end

  # Basic content quality checks
  defp check_content_quality(params) do
    message = Map.get(params, "message", "")
    name = Map.get(params, "name", "")
    subject = Map.get(params, "subject", "")
    
    cond do
      # Check for excessive links
      count_links(message) > 2 ->
        {:error, "Too many links in message"}
      
      # Check for spam keywords
      contains_spam_keywords?(message <> " " <> subject) ->
        {:error, "Message contains suspicious content"}
      
      # Check for reasonable name length
      String.length(name) > 100 ->
        {:error, "Name is too long"}
      
      # Check for suspicious patterns
      String.contains?(String.downcase(message), ["click here", "buy now", "limited time"]) ->
        {:error, "Message contains suspicious patterns"}
      
      true ->
        :ok
    end
  end

  # Simple rate limiting based on IP or session
  defp check_rate_limit(metadata) do
    ip = Map.get(metadata, :ip, "unknown")
    current_time = System.system_time(:millisecond)
    
    # Get submission history for this IP
    case get_submission_history(ip) do
      submissions when length(submissions) < @max_submissions_per_hour ->
        store_submission(ip, current_time)
        :ok
        
      submissions ->
        # Check if any submissions are within the rate limit window
        recent_submissions = 
          Enum.filter(submissions, fn timestamp ->
            current_time - timestamp < @rate_limit_window
          end)
        
        if length(recent_submissions) >= @max_submissions_per_hour do
          {:error, "Rate limit exceeded. Please wait before sending another message."}
        else
          store_submission(ip, current_time)
          :ok
        end
    end
  end

  # Check form timing (too fast = bot, too slow = suspicious)
  defp check_form_timing(metadata) do
    case Map.get(metadata, :form_start_time) do
      nil -> :ok  # Skip timing check if not available
      start_time ->
        current_time = System.system_time(:millisecond)
        fill_time = current_time - start_time
        
        cond do
          fill_time < @min_form_fill_time ->
            {:error, "Form submitted too quickly"}
          fill_time > @max_form_fill_time ->
            {:error, "Form session expired"}
          true ->
            :ok
        end
    end
  end

  # Count links in text
  defp count_links(text) do
    # Simple regex to count http/https links
    ~r/https?:\/\/[^\s]+/
    |> Regex.scan(text)
    |> length()
  end

  # Check for common spam keywords
  defp contains_spam_keywords?(text) do
    spam_keywords = [
      "viagra", "cialis", "casino", "lottery", "winner", "congratulations",
      "free money", "make money", "work from home", "business opportunity",
      "investment opportunity", "guaranteed", "risk free", "act now"
    ]
    
    text_lower = String.downcase(text)
    Enum.any?(spam_keywords, fn keyword -> String.contains?(text_lower, keyword) end)
  end

  # Simple in-memory storage for rate limiting (in production, use Redis or ETS)
  defp get_submission_history(ip) do
    case :ets.lookup(:contact_rate_limit, ip) do
      [{^ip, submissions}] -> submissions
      [] -> []
    end
  rescue
    ArgumentError ->
      # ETS table doesn't exist, create it
      :ets.new(:contact_rate_limit, [:named_table, :public])
      []
  end

  defp store_submission(ip, timestamp) do
    current_submissions = get_submission_history(ip)
    updated_submissions = [timestamp | current_submissions] |> Enum.take(10)  # Keep last 10
    :ets.insert(:contact_rate_limit, {ip, updated_submissions})
  end
end