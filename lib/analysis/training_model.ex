defmodule TrainingModel do
  @stop_words ~w(
    a about above after again against all am an and any are aren't as at be
    because been before being below between both but by can't cannot could
    couldn't did didn't do does doesn't doing don't down during each few for from
    further had hadn't has hasn't have haven't having he he'd he'll he's her here
    here's hers herself him himself his how how's i i'd i'll i'm i've if in into
    is isn't it it's its itself let's me more most mustn't my myself no nor not of
    off on once only or other ought our ours ourselves out over own same shan't
    she she'd she'll she's should shouldn't so some such than that that's the
    their theirs them themselves then there there's these they they'd they'll
    they're they've this those through to too under until up very was wasn't we
    we'd we'll we're we've were weren't what what's when when's where where's
    which while who who's whom why why's with won't would wouldn't you you'd
    you'll you're you've your yours yourself yourselves
  )

  # Store the serialized bayes model
  @redis_model_key "SERIALIZED_BAYES_MODEL"

  # Store the row we left off at when training the model
  @redis_row_key "MODEL_TRAINING_ROW"

  # Loads the tweet corpus into the model
  def training_model do
    # Open the small dataset
    corpus = "large"
    options = [
      storage: :memory,
      stem: &Stemmer.stem/1,
      stop_words: @stop_words
    ]
    {:ok, redis_client} = Exredis.start_link
    serialized_bayes_model = redis_client |> Exredis.query [
      "GET",
      @redis_model_key
    ]
    model = if serialized_bayes_model != :undefined do
      SimpleBayes.load([
        encoded_data: serialized_bayes_model
      ])
    else
      # HTTPoison.start
      # csv_stream = HTTPoison.get!(
      #  "https://s3-us-west-2.amazonaws.com/twitter-business-analysis/#{corpus}.csv"
      # ).body |>
      csv_stream = File.read!("/Users/zcotter/Downloads/large.csv") |>
        String.split("\n") |>
        List.delete("") |>
        CSV.decode
      model = train_model(
        SimpleBayes.init(options),
        csv_stream,
        redis_client
      )

      {:ok, redis_client} = Exredis.start_link


      {:ok, _process_id, serialized_bayes_model} = model |> SimpleBayes.save()

      # Save the serialized model to redis so it can be loaded faster in the
      #   future
      redis_client |> Exredis.query [
        "SET",
        @redis_model_key,
        serialized_bayes_model
      ]
      model
    end
    redis_client |> Exredis.stop
    model
  end

  defp train_model(model, csv_stream, redis_client, index \\ 0) do
    left_off_at_index = redis_client |> Exredis.query(["GET", @redis_row_key])
    if csv_stream |> Enum.empty? do
      model
    else
      skip = left_off_at_index != :undefined &&
        index < String.to_integer(left_off_at_index)
      if skip do
        # don't train the model until we get to the index we left off at
        train_model(
          model,
          csv_stream |> Stream.drop(1),
          redis_client,
          index + 1
        )
      else
        row = csv_stream |> Stream.take(1)
        IO.puts("#{index} -- #{row |> Enum.at(0)} : #{row |> Enum.at(5)}")
        redis_client |> Exredis.query(["SET", @redis_row_key, index + 1])

        train_model(
          model |> train_first_record(csv_stream |> Stream.take(1)),
          csv_stream |> Stream.drop(1),
          redis_client,
          index + 1
        )
      end

    end
  end

  defp train_first_record(model, csv_stream) do
    record = csv_stream |> first_record
    model |> SimpleBayes.train(
      first_record_sentiment(record),
      first_record_content(record)
    )
  end

  defp first_record_sentiment(record) do
    case record |> Enum.at(0) do
      "0" -> :negative
      "2" -> :neutral
      "4" -> :positive
    end
  end

  defp first_record_content(record) do
    record |> Enum.at(5)
  end

  defp first_record(stream) do
    stream |> Stream.take(1) |> Enum.to_list |> List.first
  end
end
