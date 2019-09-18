require "shrine"
require "shrine/storage/s3"
require "shrine/storage/file_system"

# if Rails.env == 'development' || Rails.env == 'test'
# 	OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
# end

s3_options = {
		access_key_id:     Rails.application.credentials[Rails.env.to_sym][:s3][:access_key_id],
		secret_access_key: Rails.application.credentials[Rails.env.to_sym][:s3][:secret_access_key],
		bucket:            'alegreme',
		endpoint:          'https://sfo2.digitaloceanspaces.com',
		region:            'sfo2'
}

# if Rails.env == 'development' || Rails.env == 'test'
# 	Shrine.storages = {
# 			cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
# 			store: Shrine::Storage::FileSystem.new("public", prefix: "uploads"),
# 	}
# else
	Shrine.storages = {
			cache: Shrine::Storage::S3.new(prefix: "cache", upload_options: {acl: 'public-read'}, **s3_options),
			store: Shrine::Storage::S3.new(prefix: "store", upload_options: {acl: 'public-read'}, **s3_options)
	}
# end


Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data # for retaining the cached file across form redisplays
Shrine.plugin :restore_cached_data # re-extract metadata when attaching a cached file
Shrine.plugin :determine_mime_type, analyzer: :mimemagic
Shrine.plugin :infer_extension, force: true

