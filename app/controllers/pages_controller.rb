class PagesController < ApplicationController
  def home
    @hide_search = true
    @specialties = Specialty.where(:is_active => true).order(:name => :asc).all

    @page_title = "Welcome to MoodyCall"
    @page_subtitle = "Real Talk. Real Time."
  end
end
