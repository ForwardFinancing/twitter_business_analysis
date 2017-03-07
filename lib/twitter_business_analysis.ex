defmodule TwitterBusinessAnalysis do

  def do_that_thang do
    # Seed the training model
    model = TrainingModel.training_model

    # Get the twitter data
    HTTPoison.start
    authorization_token = Token.token
    user = User.get("iamdevloper")
    timeline = Timeline.get("iamdevloper", 1000) |> Enum.map(fn (tweet) ->
      # Insert sentiment analysis into twitter data
      tweet |> Map.put(
        :sentiment,
        model |> SimpleBayes.classify(tweet |> Map.get(:text))
      )
    end)
    IO.inspect timeline
    # require IEx
    # IEx.pry
  end
end
TwitterBusinessAnalysis.do_that_thang
