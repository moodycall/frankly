class PagesController < ApplicationController
  def home
    @hide_search = true
    @specialties = Specialty.all
  end
end
