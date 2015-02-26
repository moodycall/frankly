class CreatePayouts < ActiveRecord::Migration
  def change
    create_table :payouts do |t|
      t.integer  :user_id
      t.integer  :total_in_cents
      t.string   :stripe_transfer_id
      t.datetime :funds_sent_dts
      t.string   :slug
      t.string   :secure_id

      t.timestamps
    end
  end
end
