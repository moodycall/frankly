class ModifySentDtsToIncludeSmsAndEmail < ActiveRecord::Migration
  def change
    rename_column :session_prompts, :sent_dts, :sent_email_dts
    add_column    :session_prompts, :sent_sms_dts, :datetime
  end
end
