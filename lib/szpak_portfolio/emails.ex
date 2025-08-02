defmodule SzpakPortfolio.Emails do
  @moduledoc """
  Email templates and functions for the portfolio application.
  """
  import Swoosh.Email

  alias SzpakPortfolio.Mailer

  @from_email "noreply@stephenszpak.com"
  @to_email "stephen@stephenszpak.com"

  @doc """
  Sends a contact form email.
  """
  def send_contact_email(params) do
    %{
      "name" => name,
      "email" => email,  
      "subject" => subject,
      "message" => message
    } = params

    email =
      new()
      |> to(@to_email)
      |> from({name, @from_email})
      |> reply_to(email)
      |> subject("Portfolio Contact: #{subject}")
      |> html_body(contact_html_body(name, email, subject, message))
      |> text_body(contact_text_body(name, email, subject, message))

    case Mailer.deliver(email) do
      {:ok, _metadata} -> {:ok, :sent}
      {:error, reason} -> {:error, reason}
    end
  end

  defp contact_html_body(name, email, subject, message) do
    """
    <h2>New Contact Form Submission</h2>
    
    <p><strong>From:</strong> #{Phoenix.HTML.html_escape(name)} (#{Phoenix.HTML.html_escape(email)})</p>
    <p><strong>Subject:</strong> #{Phoenix.HTML.html_escape(subject)}</p>
    
    <h3>Message:</h3>
    <div style="background-color: #f5f5f5; padding: 20px; border-radius: 5px; margin: 10px 0;">
      #{Phoenix.HTML.html_escape(message) |> Phoenix.HTML.safe_to_string() |> String.replace("\n", "<br>")}
    </div>
    
    <hr>
    <p style="color: #666; font-size: 12px;">
      This message was sent from the contact form on stephenszpak.com at #{DateTime.utc_now() |> DateTime.to_string()}.
    </p>
    """
  end

  defp contact_text_body(name, email, subject, message) do
    """
    New Contact Form Submission

    From: #{name} (#{email})
    Subject: #{subject}

    Message:
    #{message}

    ---
    This message was sent from the contact form on stephenszpak.com at #{DateTime.utc_now() |> DateTime.to_string()}.
    """
  end
end