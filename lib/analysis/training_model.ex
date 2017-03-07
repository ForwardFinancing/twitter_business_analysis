defmodule TrainingModel do
  # Loads the tweet corpus into the model
  def training_model do
    # Open the small dataset
    HTTPoison.start
    csv_stream = HTTPoison.get!(
      "https://s3-us-west-2.amazonaws.com/twitter-business-analysis/large.csv"
    ).body |> String.split("\n") |> List.delete("") |> CSV.decode
    train_model(SimpleBayes.init(stem: &Stemmer.stem/1), csv_stream)
  end

  defp train_model(model, csv_stream) do
    if csv_stream |> Enum.empty? do
      model
    else
      train_model(
        model |> train_first_record(csv_stream |> Stream.take(1)),
        csv_stream |> Stream.drop(1)
      )
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
