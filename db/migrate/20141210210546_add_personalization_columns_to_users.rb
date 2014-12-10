class AddPersonalizationColumnsToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :name,   									 :string
  	add_column :users, :phone,  									 :string
  	add_column :users, :gender, 									 :integer, :default => 1,     :null => false
  	add_column :users, :send_session_email_alerts, :boolean, :default => true,  :null => false
  	add_column :users, :send_session_sms_alerts,   :boolean, :default => false, :null => false
		add_column :users, :stripe_recipient_id, 			 :string
		add_column :users, :stripe_customer_id,				 :string
		add_column :users, :default_timezone,					 :string
  end
end
