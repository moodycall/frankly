desc "Schedule Charge"
task :schedule_charge => :environment do

  chargeable_sessions = CounselingSession.chargeable_sessions
  chargeable_sessions.each do |session|
    session_cost       = session.price_in_cents
    charge_description = "MoodyCall Session ##{session.secure_id}"
    if session_cost != 0
      charged = session.charge_customer(session.client_id, session_cost, charge_description)
      if charged == true
        puts "Charge for #{session.start_datetime.strftime('%b %e, %Y %I:%M%P')}"
      elsif session.should_be_cancelled
        puts "Cancelling #{session.start_datetime.strftime('%b %e, %Y %I:%M%P')} due to lack of payment."
        session.cancelled_on_dts = Time.now.utc
        if session.save
          CounselorMailer.client_cancellation(session.id).deliver
          UserMailer.counseling_session_cancellation(session.id).deliver
        end
      end
    end
  end

  chargeable_sessions.each do |session|
    if session.stripe_balance_transaction_id.present?
      puts "Updating transaction totals with processing fee"
      session.update_transaction_total(session.stripe_balance_transaction_id)
    end
  end

end
