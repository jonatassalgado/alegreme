module FollowServices
	class AssociationCreator

		def initialize(user, followable_id, followable_type)
			#raise ArgumentError, 'followable precisa ser um model' unless followable.is_a?(ApplicationRecord)

			followable_class = Object.const_get followable_type.singularize.capitalize

			@user       = user.is_a?(ApplicationRecord) ? user : User.find(user)
			@followable = followable_class.find followable_id
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
			if @user.public_send("follow_#{@followable.class.name.underscore}", @followable)
				create_response(true)
			else
				create_response(false)
			end
		end

		def destroy_transaction
			if @user.public_send("unfollow_#{@followable.class.name.underscore}", @followable)
				create_response(false)
			else
				create_response(true)
			end
		end


		def create_response(following)
			Struct.new('Response', :user, :followable, :following)
			Struct::Response.new(@user, @followable, following)
		end


	end
end