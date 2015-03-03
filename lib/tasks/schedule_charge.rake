desc "Schedule Charge"
task :schedule_charge => :environment do

  CounselingSession.chargeable_sessions.each do |session|
    session_cost       = session.price_in_cents
    charge_description = "MoodyCall Session ##{session.secure_id}"
  
    puts "Charge for #{session.start_datetime}.strftime('%b %e, %Y %I:%M%P')"
    session.charge_customer(session.client_id, session_cost, charge_description)
  end

  CounselingSession.chargeable_sessions.each do |session|
    puts "Updating transaction totals with processing fee"
    session.update_transaction_total(session.stripe_balance_transaction_id)
  end

end
