3.times do |i|
  u = User.create name: "user#{i}", email: "user#{i}@gitfab.org", password: "12345678"
  3.times do |j|
    u.projects.create name: "recipe#{j}", title: "PROJECT#{j}", description: "This is PROJECT#{j}."
  end
end
