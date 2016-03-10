Given(/^a user visits the root page$/) do
  visit '/'
end

Given(/^I see two button on page$/) do
  first(:link, 'Sign In').visible?
  find_link('Register as dispatcher').visible?
end

When(/^I click on Register as dispatcher$/) do
  click_link('Register as dispatcher')
end

When(/^It will redirect to new dispatcher registration page$/) do
  visit('/dispatchers/sign_up')
end

