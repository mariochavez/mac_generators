Rails.application.config.middleware.use OmniAuth::Builder do
  provider :provider, ENV["KEY"], ENV["SECRET"]
end
