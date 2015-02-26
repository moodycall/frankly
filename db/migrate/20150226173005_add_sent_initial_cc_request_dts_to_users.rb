class AddSentInitialCcRequestDtsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sent_initial_cc_request_dts, :datetime
  end
end
