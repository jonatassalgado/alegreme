
Geocoder.configure(
    timeout: 15,
    lookup: :google,
    api_key: Rails.application.credentials[Rails.env.to_sym][:google][:geocoding_key],
    cache: {},
)
