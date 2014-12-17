json.array!(@ratings) do |rating|
  json.extract! rating, :id, :rater_id, :rater_type, :rateable_id, :rateable_type, :comment, :stars, :session_id
  json.url rating_url(rating, format: :json)
end
