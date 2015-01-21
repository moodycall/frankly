class CreditCard < ActiveRecord::Base
	belongs_to :user
  before_create :_deactivate_previous_cards

  private

  def _deactivate_previous_cards
    user = User.find(self.user_id)
    user.credit_cards.each do |c|
      c.is_active = false
      c.save
    end
  end

end
