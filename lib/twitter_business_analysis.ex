defmodule TwitterBusinessAnalysis do

  def do_that_thang do
    HTTPoison.start
    authorization_token = Token.token
    IO.inspect User.get("iamdevloper")
  end
end
TwitterBusinessAnalysis.do_that_thang
