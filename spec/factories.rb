FactoryGirl.define do
  factory :user do
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

  factory :sensor do
    sequence(:name)  { |n| "Sensor #{n}" }
    sequence(:addressH) { |n| n}
    sequence(:addressL) { |n| n}
    controller "Controller A"
    sensor_type_id SensorType.find_by_name("generic").id

  end
 end