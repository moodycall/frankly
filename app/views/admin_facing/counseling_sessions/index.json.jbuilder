json.array!(@counseling_sessions) do |counseling_session|
  json.extract! counseling_session, :id, :start_datetime, :estimate_duration_in_minutes, :actual_duration_in_minutes, :client_id, :counselor_id, :price_in_cents, :stripe_charge_id, :slug, :secure_id, :refund_amount_in_cents, :payout_id
  json.url counseling_session_url(counseling_session, format: :json)
end
