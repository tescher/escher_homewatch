include ApplicationHelper

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-success', text: message)
  end
end

RSpec::Matchers.define :have_valid_header_and_title do |heading, page_title|
  match do |page|
    if (heading) then
      page.should have_selector('h1', text: heading)
    end
    page.should have_selector('title', text: full_title(page_title))
  end
end

RSpec::Matchers.define :have_home_title do
  match do |page|
    page.should have_selector('title', text: '| Home')
  end
end


def valid_signin(user)
  visit signin_path
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token
end