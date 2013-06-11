def full_title(page_title)
  base_title = "Slinggit"
  if page_title.empty?
    base_title
  else
    "#{base_title} | #{page_title}"
  end
end

def sign_in(user)
  visit signin_path
  fill_in "email",    with: user.email
  fill_in "password", with: user.password
  click_button "Sign in"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token
end

def fill_in_post
  fill_in 'post_hashtag_prefix', with: "bike"
  fill_in 'post_content', with: "Shizznit uhuh ... yih! lorizzle, pulvinar ac, condimentum egizzle, shizzlin dizzle izzle, diam"
  fill_in 'post_location', with: "Denver"
  fill_in 'post_price',  with: '20'
end  
