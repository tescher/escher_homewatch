require 'rails_helper'

describe "User confirmation pages" do
  subject { page }

  before(:all) {
    @user = FactoryGirl.create(:pended)
    pp @user
  }
  after(:all) { @user.delete }

  @confirmation_token = ""

  describe "Force new confirmation" do
    before { valid_signin(@user) }

    it { should have_valid_header_and_title('User Confirmation', 'User Confirmation') }

    describe "send confirmation message" do
      before do
        pp @user
        click_button "Send confirmation e-mail"
        pp @user
        @confirmation_token = @user.reload.confirmation_token
        pp @confirmation_token
      end

      it { should have_valid_header_and_title('Welcome','') }
      it { should have_success_message("Confirmation e-mail sent") }
      it { should have_link('Sign in') }

      describe "confirm user" do
        before do
          pp @confirmation_token
          visit edit_user_confirmation_path(@confirmation_token)
        end

        it { should have_valid_header_and_title('Welcome', '') }
        it { should have_success_message('User record has been confirmed') }
        it { should have_link('Sign in') }

      end
    end
  end

end