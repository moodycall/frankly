class AddStripeFieldsToPayouts < ActiveRecord::Migration
  def change
    add_column :payouts, :stripe_balance_transaction_id, :string
    add_column :payouts, :stripe_processing_fee_in_cents, :integer
  end
end
