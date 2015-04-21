class RemoveUnconfirmedEmail < ActiveRecord::Migration
  def change
    remove_column :users, :unconfirmed_email,    :string
  end
end
