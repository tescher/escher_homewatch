require 'spec_helper'

describe "Static pages" do

  subject { page }


  describe "Home page" do
    before { visit root_path }
    it { should have_valid_header_and_title('Sample App', '') }
    it { should_not have_home_title }
  end

  describe "Help page" do
    before { visit help_path }
    it { should have_valid_header_and_title('Help', 'Help') }

  end

  describe "About page" do
    before { visit about_path }
    it { should have_valid_header_and_title('About', 'About Us') }
  end

  describe "Contact page" do
    before { visit contact_path }
    it { should have_valid_header_and_title('Contact', 'Contact') }
 end

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    page.should have_valid_header_and_title(nil, 'About Us')
    click_link "Help"
    page.should have_valid_header_and_title(nil, 'Help')
    click_link "Contact"
    page.should have_valid_header_and_title(nil, 'Contact')
    click_link "Home"
    click_link "Sign up now!"
    page.should have_valid_header_and_title(nil, 'Sign up')
    click_link "sample app"
    page.should # fill in
  end
end