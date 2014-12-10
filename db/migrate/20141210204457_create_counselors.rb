class CreateCounselors < ActiveRecord::Migration
  def change
    create_table :counselors do |t|
      t.text     :bio
      t.string   :photo
      t.date     :profession_start_date
      t.string   :slug
      t.integer  :user_id
      t.integer  :hourly_rate_in_cents,         :default => 6000,  :null => false
      t.integer  :hourly_fee_in_cents,          :default => 600,   :null => false
      t.boolean  :send_session_sms_alerts,      :default => false, :null => false
      t.boolean  :send_session_email_alerts,    :default => true,  :null => false
      t.integer  :advanced_scheduling_in_weeks, :default => 4,     :null => false
      t.boolean  :available_monday,             :default => true,  :null => false
      t.boolean  :available_tuesday,            :default => true,  :null => false
      t.boolean  :available_wednesday,          :default => true,  :null => false
      t.boolean  :available_thursday,           :default => true,  :null => false
      t.boolean  :available_friday,             :default => true,  :null => false
      t.boolean  :available_saturday,           :default => false, :null => false
      t.boolean  :available_sunday,             :default => false, :null => false

      t.timestamps
    end
  end
end
