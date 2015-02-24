class AddOpentokSessionIdToCounselingSessions < ActiveRecord::Migration
  def change
    add_column :counseling_sessions, :opentok_session_id, :string
  end
end
