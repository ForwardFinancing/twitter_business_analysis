defmodule Request do
  use HTTPoison.Base

  def process_url(path) do
    IO.puts("https://api.twitter.com/" <> path)
    "https://api.twitter.com/" <> path
  end

  def process_request_headers(headers) do
    # TODO Right now we get a token for every request, should refactor to
    # memoize tokens until expiration or process death
    headers ++ [
      {"Authorization", "Bearer " <> Token.token}
    ]
  end

  def process_response_body(body) do
    body |> Poison.decode!
  end

  # TODO handle response auth edge cases defined in https://dev.twitter.com/oauth/application-only
end
