class User < ActiveRecord::Base

	has_one :counselor
  has_many :counseling_sessions, :foreign_key => 'client_id'
  has_many :credit_cards
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_save :_create_stripe_customer_id

  def session_count_with_counselor(counselor_id)
    counseling_sessions.where(:counselor_id => counselor_id).count
  end

  def upcoming_sessions
    counseling_sessions.where("start_datetime >= ?", Time.zone.now)
  end

  private
  
  def _create_stripe_customer_id
  	unless stripe_customer_id.present?
	  	customer = Stripe::Customer.create(
			  :email => "#{self.email}",
			  :description => "MoodyCall Customer"
			)

			self.stripe_customer_id = customer.id
			self.save
		end

  end
end
