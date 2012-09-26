FactoryGirl.define do 
  factory :user do
    email                 "pablo@example.com"
    password              "foobar"
    password_confirmation "foobar"
  end
  
  factory :admin do
    email                 "pablo@example.com"
    password              "foobar"
    password_confirmation "foobar"
    admin                 true
  end
  
  factory :session do
    time Time.now
    association :user
  end
  
  sequence :email do |n|
    "person-#{n}@example.com"  
  end
  
end