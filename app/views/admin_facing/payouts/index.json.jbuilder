json.array!(@payouts) do |payout|
  json.extract! payout, :id, :user_id, :total_in_cents, :stripe_transfer_id
  json.url payout_url(payout, format: :json)
end
