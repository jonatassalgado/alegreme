# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
	# GET /resource/password/new
	# def new
	#   super
	# end

	# POST /resource/password
	# def create
	#   super
	# end

	# GET /resource/password/edit?reset_password_token=abcdef
	def edit
		@user                      = User.with_reset_password_token params[:reset_password_token]
		@user.reset_password_token = params[:reset_password_token]

		set_minimum_password_length
	end

	# PUT /resource/password
	# def update
	#   super
	# end

	# protected

	# def after_resetting_password_path_for(resource)
	#   super(resource)
	# end

	# The path used after sending reset password instructions
	# def after_sending_reset_password_instructions_path_for(resource_name)
	#   super(resource_name)
	# end
end
