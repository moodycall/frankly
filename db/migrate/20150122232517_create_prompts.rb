class CreatePrompts < ActiveRecord::Migration
  def change
    create_table :prompts do |t|
      t.string   :name
      t.string   :slug
      t.integer  :quantity,            default: 1,    null: false
      t.integer  :interval,            default: 1,    null: false
      t.boolean  :send_before_session, default: true, null: false
      t.boolean  :enable_sms,          default: true, null: false
      t.text     :sms_message
      t.boolean  :enable_email,        default: true, null: false
      t.text     :email_message
      t.integer  :audience_type,       default: 1,    null: false
      t.boolean  :is_active,           default: true, null: false
      t.string   :secure_id

      t.timestamps
    end
  end
end
