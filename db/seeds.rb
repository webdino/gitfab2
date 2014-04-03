10.times do |t|
  User.create(name: "user#{t}", email: "user#{t}@gitfab.org", password: "password")
end
