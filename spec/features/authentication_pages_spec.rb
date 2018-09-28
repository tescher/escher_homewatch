require 'rails_helper'

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_valid_header_and_title('Sign in', 'Sign in') }

  end

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_valid_header_and_title('Sign in', 'Sign in') }
      it { should have_error_message('Invalid') }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_error_message }
      end
    end

    describe "with valid information" do

      let(:user) { FactoryBot.create(:user) }
      before { valid_signin(user) }

      it { should have_selector("title", text: "Monitor", visible: false) }

      it { should_not have_link('Users',    href: users_path) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Settings', href: edit_user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }

      it { should_not have_link('Sign in', href: signin_path) }

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end

      describe "with admin user" do
        let(:admin) { FactoryBot.create(:admin) }
        before { valid_signin(admin) }
        it { should have_link('Users',    href: users_path) }
      end

      describe "as pending user" do
        let(:pended) { FactoryBot.create(:pended) }
        before { valid_signin(pended) }
        it { should have_valid_header_and_title('User Confirmation', 'User Confirmation') }
        it { should have_error_message('not confirmed') }
        describe "send confirmation again" do
          before { click_button "Send confirmation e-mail" }
          it { should have_valid_header_and_title('Welcome', '') }
          it { should have_success_message('Confirmation e-mail sent') }
        end
      end


    end

    describe "forgot password" do
      before { click_link "Forgot password?" }
      it { should have_valid_header_and_title('Password Reset', 'Password Reset') }
    end

  end

  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user) { FactoryBot.create(:user) }

      describe "in the Users controller" do

        describe "visiting the home page" do
          before { visit root_path }
          it { should_not have_link('Profile', href: user_path(user)) }
          it { should_not have_link('Settings', href: edit_user_path(user)) }
          it { should_not have_link('Sign out', href: signout_path) }
        end

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_valid_header_and_title(nil, 'Sign in') }
        end

        describe "visiting the profile page" do
          before { visit user_path(user) }
          it { should have_valid_header_and_title(nil, 'Sign in') }
        end

        describe "submitting to the update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(signin_path) }
        end

        describe "when attempting to visit a protected page" do
          before do
            visit edit_user_path(user)
            fill_in "Email",    with: user.email
            fill_in "Password", with: user.password
            click_button "Sign in"
          end

          describe "after signing in" do

            it "should render the desired protected page" do
              page.should have_selector('title', text: 'Edit user', visible: false)
            end

            describe "when signing in again" do
              before do
                delete signout_path
                visit signin_path
                fill_in "Email",    with: user.email
                fill_in "Password", with: user.password
                click_button "Sign in"
              end

              it "should render the default page" do
                page.should have_selector("title", text: 'Monitor', visible: false)
              end
            end
          end
        end

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_valid_header_and_title('Homewatch', '') }
        end

      end
    end

    describe "as wrong user" do
      let(:user) { FactoryBot.create(:user) }
      let(:wrong_user) { FactoryBot.create(:user, email: "wrong@example.com") }
      before { valid_signin user }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_selector('title', text: full_title('Edit user')) }
      end

      describe "submitting a PUT request to the Users#update action" do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to(signin_path) }
      end

      describe "profile page" do
        before { visit user_path(wrong_user) }
       it { should have_valid_header_and_title('Homewatch', '') }
      end

    end

    describe "as non-admin user" do
      let(:user) { FactoryBot.create(:user) }
      let(:non_admin) { FactoryBot.create(:user) }

      before { valid_signin non_admin }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { response.should redirect_to(signin_path) }
      end
    end

    describe "as signed in user" do
      let(:user) { FactoryBot.create(:user) }
      before(:each) { valid_signin user }

      describe "trying to sign up" do
        before { visit signup_path }
        specify { current_path.should == root_path }
      end

      describe "trying to create user" do
        before { page.driver.post signup_path }
        specify { page.should have_current_path(root_path) }
      end
    end


  end


end
