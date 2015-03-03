class AddStripeProcessingFeeToCounselingSessions < ActiveRecord::Migration
  def change
    add_column :counseling_sessions, :stripe_processing_fee_in_cents, :integer
  end
end
