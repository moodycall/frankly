class CreateCounselingSessions < ActiveRecord::Migration
  def change
    create_table :counseling_sessions do |t|
      t.datetime :start_datetime
      t.integer  :estimate_duration_in_minutes
      t.integer  :actual_duration_in_minutes
      t.integer  :client_id
      t.integer  :counselor_id
      t.integer  :price_in_cents
      t.string   :stripe_charge_id
      t.string   :slug
      t.string   :secure_id
      t.integer  :refund_amount_in_cents
      t.integer  :payout_id

      t.timestamps
    end
  end
end
