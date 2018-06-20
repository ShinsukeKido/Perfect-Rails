class UsersController < ApplicationController
  before_action :authenticate

  def destroy
    if current_user.destroy
      session.delete(:user_id)
      redirect_to root_path, notice: '退会完了しました'
    else
      render :retire
    end
  end
end
