defmodule Token do
  @moduledoc """
    Acquire and return authentication bearer token as described in steps 1 and 2
    in Twitters docs https://dev.twitter.com/oauth/application-only
  """

  use HTTPoison.Base

  """
    The Twitter token endpoint returns these fields in its JSON response
  """
  @expected_fields ~w(
    access_token
    token_type
  )

  @doc """
    Retrieve and return an authentication bearer token to use with future API
    requests
  """
  def token do
    # Make the request to the token endpoint
    token_response = Token.post!("/oauth2/token", nil)

    # The twitter API docs request that we validate the token_type is "bearer"
    case token_response.body[:token_type] do
      "bearer" -> token_response.body[:access_token]
      other -> raise "API returned invalid token type " <> other
    end
  end

  @doc """
  The token endpoint
  """
  def process_url(path) do
    "https://api.twitter.com/" <> path
  end

  @doc """
  The request body required by twitter
  """
  def process_request_body(body) do
    "grant_type=client_credentials"
  end

  @doc """
  Adds the headers required by twitter
  """
  def process_request_headers(headers) do
    consumer_key = URI.encode(
      Application.get_env(:twitter_business_analysis, :consumer_key)
    )
    consumer_secret = URI.encode(
      Application.get_env(:twitter_business_analysis, :consumer_secret)
    )
    basic_auth_value = [
      consumer_key,
      ":",
      consumer_secret
    ] |> Enum.join |> Base.encode64
    headers ++ [
      {"Content-Type", "application/x-www-form-urlencoded;charset=UTF-8"},
      {"Authorization", "Basic " <> basic_auth_value}
    ]
  end

  @doc """
  Decodes the JSON response and maps string keys to atoms
  """
  def process_response_body(body) do
    body |>
      Poison.decode! |>
      Map.take(@expected_fields) |>
      Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end
end
