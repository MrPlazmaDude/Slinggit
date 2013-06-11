Twitter.configure do |config|
	
  config.consumer_key = Rails.configuration.twitter_consumer_key
  config.consumer_secret = Rails.configuration.twitter_consumer_secret

end
