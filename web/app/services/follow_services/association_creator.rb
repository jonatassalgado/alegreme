module FollowServices
	class AssociationCreator

		def initialize(user, followable)
			raise ArgumentError, 'followable precisa ser um model' unless followable.is_a?(ApplicationRecord)

			@user       = user.is_a?(ApplicationRecord) ? user : User.find(user)
			@followable = followable
		end

		def call(opts = {})
			@opts = opts

			if opts[:destroy]
				destroy_transaction
			else
				create_transaction
			end
		end

		private

		def create_transaction
			if @user.follow(@followable)
				create_response(true)
			else
				create_response(false)
			end
		end

		def destroy_transaction
			if @user.stop_following(@followable)
				create_response(true)
			else
				create_response(false)
			end
		end


		def create_response(success)
			Struct.new('Response', :user, :followable, :saved?)
			Struct::Response.new(@user, @followable, success)
		end


	end
end