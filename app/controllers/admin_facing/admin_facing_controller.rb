class AdminFacingController < ApplicationController
  before_action :authenticate_user!
  # before_action :_ensure_user_is_admin

  private

  # def _ensure_user_is_admin
  #   unless current_user and current_user.is_admin
  #     redirect_to root_url(:subdomain => "www"), :notice => "Welcome to BreezePort. Feel free to look around on our public site."
  #   end
  # end
end
