class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by_email(params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if !user.active?
        flash[:error] = 'Your user record is not confirmed. Follow instructions on your confirmation e-mail or click below to re-send the e-mail.'
        redirect_to new_user_confirmation_path email: user.email
      else
        sign_in user
        redirect_back_or user
      end
    else
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

  def isadmin
    if signed_in?
      if current_user.admin?
        puts "Rendering true"
        render text: 'true'
      else
        puts "Rendering false"
        render text: 'false'
      end
    else
      render nothing: true
    end
  end
end
