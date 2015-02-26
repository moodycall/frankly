desc "Generating Payouts"
task :generate_payouts => :environment do

  # Handle Email Prompts
  @payable_counselors = Counselor.payable_counselors

  @payable_counselors.each do |counselor|
    new_payout = Payout.new
    
    new_payout.user           = counselor.user
    new_payout.total_in_cents = counselor.payable_total_in_cents

    if new_payout.save
      counselor.payable_sessions.each do |session|
        session.payout_id = new_payout.id
        session.save
      end
    end
  end
end
