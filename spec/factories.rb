Factory.define :user do |user|
  user.email                 "pablo@example.com"
  user.password              "foobar"
  user.password_confirmation "foobar"
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end

Factory.define :session do |session|
  session.time Time.now
  session.association :user
end