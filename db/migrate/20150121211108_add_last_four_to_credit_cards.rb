class AddLastFourToCreditCards < ActiveRecord::Migration
  def change
    add_column :credit_cards, :last_four, :string
  end
end
