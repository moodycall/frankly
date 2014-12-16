json.array!(@favorite_counselors) do |favorite_counselor|
  json.extract! favorite_counselor, :id, :user_id, :counselor_id
  json.url favorite_counselor_url(favorite_counselor, format: :json)
end
