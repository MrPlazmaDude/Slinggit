FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person#{n}" }
    sequence(:email) { |n| "person_#{n}@nowaythisisadomain.com"}   
    password "foobar"
    password_confirmation "foobar"
    status "ACT"
    photo_source "SPS"

    factory :admin do
      admin true
    end

  end

  factory :post do
    content "In dope bow wow whw its fo rizzle nisi. Mammasay mammasa bamma oo sa rhoncizzle."
    hashtag_prefix "bike"
    location "Denver"
    price '20'
    user
  end

  # Default factory is twitter api account.  Override necassary values for
  # facebook api
  factory :api_account do
    user_id 1
    api_id '1234'
    api_source 'twitter'
    oauth_token 'accountToken'
    oauth_secret 'accountSecret'
    real_name 'mitch cumstein'
    user_name 'mitchcumstein'
    image_url 'http://a0.twimg.com/sticky/default_profile_images/mitchcumstein.png'
    description ''
    language 'en'
    location 'Denver'
    status 'PRM'
    reauth_required 'no'
  end

  factory :twitter_post do
    api_account
    post
    user_id 1
    twitter_post_id '123456789'
    content '#forsale #bike In dope bow wow whw its fo rizzle nisi. Mammasay mammasa bamma oo sa rhoncizzle. | $20'
    status 'SUC'
  end

  factory :facebook_post do
    api_account
    post
    user_id 1
    facebook_post_id '123456789_987654321'
    name '$20'
    message '#forsale #bike'
    description 'In dope bow wow whw its fo rizzle nisi. Mammasay mammasa bamma oo sa rhoncizzle.'
    status 'SUC'
  end

end