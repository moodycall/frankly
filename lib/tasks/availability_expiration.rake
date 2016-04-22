desc "Availability Expiration Notice"
task :availability_expiration  => :environment do
  currentDate = (Time.now.utc + 5.days).strftime("%Y-%m-%d")
  counselors = Counselor.find_by_sql("select users.email, users.first_name from counselors 
                inner join users on counselors.user_id = users.id 
                inner join availability_days on availability_days.counselor_id = counselors.id 
                where counselors.is_active = true 
                and availability_days.active = true 
                and availability_days.available_date = '#{currentDate}' 
                and counselors.id not in (select counselor_id from availability_days as 
                  where as.active = true and as.available_date > '#{currentDate}')")

  counselors.each do |c|
    puts "#{c.first_name}"
    CounselorMailer.availability_expired_notice(c).deliver
  end
  
end