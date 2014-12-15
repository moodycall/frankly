class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.integer  :user_id
      t.string   :name
      t.string   :stripe_card_id
      t.boolean  :is_active, :default => true, :null => false

      t.timestamps
    end
  end
end
