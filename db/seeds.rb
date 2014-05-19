3.times do |i|
  u = User.create name: "user#{i}", email: "user#{i}@gitfab.org", password: "12345678", password_confirmation: "12345678"
  3.times do |j|
    u.recipes.create name: "recipe#{j}", title: "RECIPE#{j}", description: "This is RECIPE#{j}."
  end
end
