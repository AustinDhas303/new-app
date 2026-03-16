User.create!(
  name: "Example User",
  email: "example@user.com",
  password: "password",
  password_confirmation: "password",
  admin: true,
  activated: true,
  activated_at: Time.zone.now

)
99.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@user.com"
  password = "password"
  User.create!(
    name: name,
    email: email,
    password: password,
    password_confirmation: password,
    activated: false,
    activated_at: Time.zone.now
  )
end

users = User.order(:created_at).first(6)
50.times do
  content = Faker::Lorem.sentence(word_count: 5)
  users.each {|user| user.microposts.create!(content: content)}
end