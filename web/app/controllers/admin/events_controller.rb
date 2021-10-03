module Admin
	class EventsController < Admin::ApplicationController

		def default_sorting_attribute
			:updated_at
		end

		def default_sorting_direction
			:desc
		end

		# Overwrite any of the RESTful controller actions to implement custom behavior
		# For example, you may want to send an email after a foo is updated.
		#
		def create
			resource = resource_class.new(resource_params)
			authorize_resource(resource)

			if resource.save
				if resource.active_status
					PredictEventLabels.predict(resource)
					PredictSimilarEvents.predict(resource)
				end
				redirect_to(
					[namespace, resource],
					notice: translate_with_resource("create.success"),
				)
			else
				render :new, locals: {
					page: Administrate::Page::Form.new(dashboard, resource),
				}, status:           :unprocessable_entity
			end
		end

		def update
			if requested_resource.update(resource_params)
				if requested_resource.active_status
					PredictEventLabels.predict(requested_resource)
					PredictSimilarEvents.predict(requested_resource)
				end
				redirect_to(
				[namespace, requested_resource],
				notice: translate_with_resource("update.success"),
				)
			else
				render :edit, locals: {
				page: Administrate::Page::Form.new(dashboard, requested_resource),
				}, status: :unprocessable_entity
			end
		end

		# Override this method to specify custom lookup behavior.
		# This will be used to set the resource for the `show`, `edit`, and `update`
		# actions.
		#
		def find_resource(param)
			if params[:id].numeric?
				Event.find(params[:id])
			else
				Event.friendly.find(params[:id])
			end
		end

		# The result of this lookup will be available as `requested_resource`

		# Override this if you have certain roles that require a subset
		# this will be used to set the records shown on the `index` action.
		#
		# def scoped_resource
		#   if current_user.super_admin?
		#     resource_class
		#   else
		#     resource_class.with_less_stuff
		#   end
		# end

		# Override `resource_params` if you want to transform the submitted
		# data before it's persisted. For example, the following would turn all
		# empty values into nil values. It uses other APIs such as `resource_class`
		# and `dashboard`:
		#
		def resource_params
			params["event"]["datetimes"] = params["event"]["datetimes"].split(" ")
			params.require(resource_class.model_name.param_key).permit(*dashboard.permitted_attributes, datetimes: [])
		end

		# See https://administrate-prototype.herokuapp.com/customizing_controller_actions
		# for more information
	end
end
