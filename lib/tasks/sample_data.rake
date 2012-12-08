namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    admin = User.create!(name: "Example User",
                 email: "example@eschers.com",
                 password: "foobar",
                 password_confirmation: "foobar")
    admin.toggle!(:admin)
    admin.activate!
    99.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@eschers.com"
      password  = "password"
      user = User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
      user.activate!
    end
  end
  desc "Seed with the reference data"
  namespace :test do
    task :prepare => :environment do
      Rake::Task["db:seed"].invoke
    end
  end
end