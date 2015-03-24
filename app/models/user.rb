class User < ActiveRecord::Base
  include StripeInteractions
  
	has_one :counselor
  has_many :counseling_sessions, :foreign_key => 'client_id'
  has_many :credit_cards
  has_many :favorite_counselors
  has_many :ratings, as: :rater
  has_many :payouts

  has_many :session_prompts
  has_many :prompts, through: :session_prompts

  mount_uploader :photo, ProfilePhotoUploader
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_save :_create_stripe_customer_id
  before_create :_collect_details_from_full_contact

  def session_count_with_counselor(counselor_id)
    counseling_sessions.where(:counselor_id => counselor_id).count
  end

  def upcoming_sessions
    counseling_sessions.where(:cancelled_on_dts => nil).where("start_datetime >= ?", Time.zone.now)
  end

  def previous_sessions
    counseling_sessions.where("start_datetime <= ?", Time.zone.now)
  end

  def current_card
    if credit_cards.where(:is_active => true).present?
      credit_cards.where(:is_active => true).order(:created_at => :asc).first
    else
      return false
    end
  end
  
  def first_name
    name.scan(/\w+/).first
  end

  def paid_counseling_sessions
    counseling_sessions.where.not(:stripe_charge_id => nil).all
  end

  def session_starting_soon
    if counseling_sessions.where(start_datetime: (Time.zone.now - 5.minutes)..(Time.zone.now + 20.minutes)).present?
      counseling_sessions.where(start_datetime: (Time.zone.now - 5.minutes)..(Time.zone.now + 20.minutes)).first
    else
      return false
    end
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

  def _collect_details_from_full_contact
    person      = FullContact.person(email: self.email)

    # Only Facebook image is large enough so it's the only image we want to use
    facebook_photo = person.photos.select {|s| s.type? 'facebook'}.first.url
    self.photo  = facebook_photo
    if person and person.demographics.present? and person.demographics.gender.present? and person.demographics.gender == "Female"
      self.gender = 2
    end

    # If FullContact Fails, we don't care about throwing an error
    # This should get moved into a background process in the future
    rescue NoMethodError
    rescue FullContact::NotFound
  end
end
