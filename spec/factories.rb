FactoryGirl.define do
  factory :user do |user|
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@eschers.com"}
    password "foobar"
    password_confirmation "foobar"
    state :active

    factory :admin do
      admin true
    end

    factory :pended do
      state :pended
    end

  end
 end