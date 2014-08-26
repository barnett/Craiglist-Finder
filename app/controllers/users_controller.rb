class UsersController < ApplicationController
  before_filter :authenticate_user!

  def update
    current_user.update_attributes(user_attributes)
    redirect_to rooms_path
  end

  private

  def user_attributes
    params.require(:user).permit(:url, :message, :subject)
  end

end
