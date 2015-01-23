class CreateSessionPrompts < ActiveRecord::Migration
  def change
    create_table :session_prompts do |t|
      t.integer  :prompt_id
      t.integer  :session_id
      t.integer  :user_id
      t.datetime :sent_dts

      t.timestamps
    end
  end
end
