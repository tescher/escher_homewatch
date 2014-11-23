require 'rails_helper'

describe "Password reset pages" do
  subject { page }

  before(:all) { @user = FactoryGirl.create(:user) }
  after(:all) { @user.delete }

  @password_reset_token = ""

  describe "reset request (new)" do
    before { visit new_password_reset_path }

    it { should have_valid_header_and_title('Password Reset', 'Password Reset') }

    describe "send reset message" do
      before do
        fill_in "Email",    with: @user.email
        click_button "Get new password"
        @password_reset_token = @user.reload.password_reset_token
        pp @password_reset_token
      end

      it { should have_valid_header_and_title('Welcome','') }
      it { should have_success_message("Email sent") }

      describe "password update" do
        before do
          pp @password_reset_token
          visit edit_password_reset_path(@password_reset_token)
        end

        it { should have_valid_header_and_title('Update Password', 'Update Password') }

        describe "with invalid information" do
          before do
            fill_in "Password",   with: "foobar"
            click_button "Update Password"
          end
          it { should have_selector('li', text: "Password") }
        end

        describe "with valid information" do
          before do
            fill_in "Password",         with: "foobar"
            fill_in "Confirm Password", with: "foobar"
            click_button "Update Password"
          end

          it { should have_valid_header_and_title('Welcome', '') }
          it { should have_success_message('Password has been reset') }
          it { should have_link('Sign in') }

        end
      end
    end
  end

end