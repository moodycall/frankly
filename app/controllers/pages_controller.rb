class PagesController < ApplicationController
  before_filter :checkIsCounselor!
  def home
    @hide_search = true
    @specialties = Specialty.where(:is_active => true).order(:name => :asc).all

    @page_title = "Welcome to MoodyCall"
    @page_subtitle = "Real Talk. Real Time."
  end

  def checkIsCounselor!
    if user_signed_in? and current_user.is_counselor and !current_user.counselor.present?
      redirect_to new_counselor_path, :notice => "Please fill in the form to continue"
    else
      # super
    end
  end
end
