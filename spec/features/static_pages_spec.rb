require 'rails_helper'

describe "Static pages" do


  subject { page }

  describe "Home page" do
    before {
      visit root_path
    }
    it { should have_valid_header_and_title('Welcome to Homewatch', '') }
    it { should_not have_home_title }
  end

  describe "Help page" do
    before { visit help_path }
    it { should have_valid_header_and_title('Help', 'Help') }

  end

  describe "About page" do
    before { visit about_path }
    it { should have_valid_header_and_title('About Us', 'About Us') }
  end

  describe "Contact page" do
    before { visit contact_path }
    it { should have_valid_header_and_title('Contact Us', 'Contact Us') }
 end

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    should have_valid_header_and_title('About Us', 'About Us')
    click_link "Help"
    should have_valid_header_and_title('Help', 'Help')
    click_link "Contact"
    should have_valid_header_and_title('Contact Us', 'Contact Us')
    click_link "Home"
    click_link "Sign up now!"
    should have_valid_header_and_title(nil, 'Sign up')
    click_link "Homewatch"
    should # fill in
  end
end