module UserConfirmationsHelper

  def send_user_confirmation
    if !@user
      @user = User.find_by_email(params[:email])
    end
    @user.send_confirmation if @user
    flash[:success] = "Confirmation e-mail sent with instructions to activate account."
  end

end
