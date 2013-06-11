namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    admin = User.create!(name: "Chris Klein",
                 email: "chrisklein@nomabi.com",
                 password: "foobar",
                 password_confirmation: "foobar")
    admin.toggle!(:admin)
    99.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password  = "password"
      User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end

    users = User.all(limit: 6)
    50.times do
      hashtag_prefix = "Bike"
      content = Faker::Lorem.sentence(3)
      price = 20
      photo = File.open(Dir.glob(File.join(Rails.root, 'sampleimages', '*')).sample)
      users.each { |user| user.posts.create!(hashtag_prefix: hashtag_prefix, photo: photo,
                                             content: content, price: price) }
    end
  end
end