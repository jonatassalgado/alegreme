
Geocoder.configure(
    timeout: 15,
    lookup: :google,
    api_key: Rails.application.credentials[Rails.env.to_sym][:google][:alegreme_api],
    cache: {},
)
