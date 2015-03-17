class AddStripeRefundIdToCounselingSessions < ActiveRecord::Migration
  def change
    add_column :counseling_sessions, :stripe_refund_id, :string
  end
end
