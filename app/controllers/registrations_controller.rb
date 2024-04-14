# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController
    def create
      super do |resource|
        if params[:user][:province_id].present?
          resource.province_id = params[:user][:province_id]
        end
      end
    end
  
    private
  
    def sign_up_params
      params.require(:user).permit(:email, :password, :password_confirmation, :province_id)
    end
  end
  