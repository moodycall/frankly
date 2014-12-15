class User < ActiveRecord::Base

	has_one :counselor
  has_many :counseling_sessions
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_save :_create_stripe_customer_id

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
