class AddBalanceTransactionToCounselingSessions < ActiveRecord::Migration
  def change
    add_column :counseling_sessions, :stripe_balance_transaction_id, :string
  end
end
