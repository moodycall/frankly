class Payout < ActiveRecord::Base

  extend FriendlyId
  friendly_id :slug, use: [:slugged, :history, :finders]

  belongs_to :user
  has_many :counseling_sessions

  before_create :_generate_secure_id

  def total_in_dollars
    total_in_cents * 0.01
  end

  def transfer_funds
    # Create a transfer to the specified recipient
    transfer = Stripe::Transfer.create(
      :amount => total_in_cents, # amount in cents
      :currency => "usd",
      :recipient => user.stripe_recipient_id,
      :statement_descriptor => "Payout from MoodyCall | #{id}"
    )

    self.stripe_transfer_id = transfer.id
    self.funds_sent_dts     = Time.now
    self.save
  end

  def self.total_funds_payable_in_cents
    total = 0
    self.where(:funds_sent_dts => nil).each do |payout|
      total += payout.total_in_cents
    end
    total
  end

  def self.total_funds_payable_in_dollars
    self.total_funds_payable_in_cents * 0.01
  end

  def self.total_sessions_payable
    total_sessions = 0
    self.where(:funds_sent_dts => nil).each do |payout|
      total_sessions += payout.counseling_sessions.count
    end
    total_sessions
  end

  private

  def _generate_secure_id
    unless self.secure_id.present?
      self.secure_id = "PY#{Time.now.strftime('%y%m%d')}#{SecureRandom.hex(2).upcase}"
      self.slug      = self.secure_id
    end
  end
end