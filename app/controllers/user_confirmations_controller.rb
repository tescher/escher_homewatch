class UserConfirmationsController < ApplicationController

  def new
  end

  def create
    @user = User.find_by_email(params[:email])
    send_user_confirmation
    redirect_to root_url
  end

  def edit
    update
  end

  def update
    @user = User.find_by_confirmation_token!(params[:id])
    if @user && @user.activate!
      @user.confirmation_token = ""    # Kill off token, been used
      flash[:success] = "User record has been confirmed."
      redirect_to root_url
    else
      flash[:error] = "User could not be confirmed. Try re-creating account or click below to re-send e-mail."
      params[:email] = @user.email
      render 'new'
    end
  end
end
