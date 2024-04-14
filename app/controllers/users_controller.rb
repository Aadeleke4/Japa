# app/controllers/users_controller.rb
class UsersController < ApplicationController
    before_action :authenticate_user!
  
    def edit
      @user = current_user
    end
  
    def update
      @user = current_user
      if @user.update(user_params)
        redirect_to root_path, notice: 'Address updated successfully.'
      else
        render :edit
      end
    end
  
    private
  
    def user_params
      params.require(:user).permit(:address, :province_id)
    end
  end
  