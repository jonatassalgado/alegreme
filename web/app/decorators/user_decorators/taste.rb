module UserDecorators
	module Taste

		TASTE_TYPES = {
				"save"      => {
						past:   "saved",
						plural: "saves"
				},
				"unsave"    => {
						past:   "saved",
						plural: "saves"
				},
				"like"      => {
						past:   "liked",
						plural: "likes"
				},
				"unlike"    => {
						past:   "liked",
						plural: "likes"
				},
				"view"      => {
						past:   "viewed",
						plural: "views"
				},
				"dislike"   => {
						past:   "disliked",
						plural: "dislikes"
				},
				"undislike" => {
						past:   "disliked",
						plural: "dislikes"
				}
		}

		RESOURCES = ['events', 'movies']

		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end


		module InstanceMethods

			RESOURCES.each do |resource|
				define_method "saved_#{resource}" do |opts = {}|
					if self && self.public_send("taste_#{resource}_saved").present?
						resource.classify.constantize.saved_by_user(self)
					else
						resource.classify.constantize.none
					end
				end
			end

			RESOURCES.each do |resource|
				define_method "saved_#{resource}_ids" do
					if self && !self.public_send("taste_#{resource}_saved").empty?
						if resource == 'events'
							Event.saved_by_user(self).active.order_by_date.uniq.pluck(:id)
						elsif resource == 'movies'
							Movie.saved_by_user(self).order_by_date.uniq.pluck(:id)
						end
					else
						resource.classify.constantize.none
					end
				end
			end

			RESOURCES.each do |resource|
				["save", "like", "view", "dislike"].each do |taste_type|
					define_method "taste_#{resource}_#{taste_type}" do |resource_id|
						begin
							instance = resource.classify.constantize.find resource_id.to_i

							ActiveRecord::Base.transaction do
								instance.entries["#{TASTE_TYPES[taste_type][:past]}_by"]      |= [id]
								instance.entries["total_#{TASTE_TYPES[taste_type][:plural]}"] += 1

								validate_taste_existence resource
								taste[resource][TASTE_TYPES[taste_type][:past]]              |= [resource_id.to_i]
								taste[resource]["total_#{TASTE_TYPES[taste_type][:plural]}"] += 1
								taste[resource]['updated_at']                                = DateTime.now

								instance.save && save
							end
						rescue ActiveRecord::RecordInvalid
							puts 'Não foi possível salvar sua ação (ERRO 7813)!'
						else
							if taste_type == "save" && resource == 'events'
								UpdateUserEventsSuggestionsJob.perform_later(self.id)
							end

							return taste_type
						end
					end
				end
			end

			RESOURCES.each do |resource|
				["unsave", "unlike", "unview", "undislike"].each do |taste_type|
					define_method "taste_#{resource}_#{taste_type}" do |resource_id|
						begin
							instance = resource.classify.constantize.find resource_id.to_i

							ActiveRecord::Base.transaction do
								instance.entries["#{TASTE_TYPES[taste_type][:past]}_by"].delete id
								instance.entries["total_#{TASTE_TYPES[taste_type][:plural]}"] -= 1

								validate_taste_existence resource
								taste[resource][TASTE_TYPES[taste_type][:past]].delete resource_id.to_i
								taste[resource]["total_#{TASTE_TYPES[taste_type][:plural]}"] -= 1
								taste[resource]['updated_at']                                = DateTime.now

								instance.save && save
							end
						rescue ActiveRecord::RecordInvalid
							puts 'Não foi possível salvar sua ação (ERRO 7813)!'
							return false
						else
							if taste_type == "unsave" && resource == 'events'
								UpdateUserEventsSuggestionsJob.perform_later(self.id)
							end

							return taste_type
						end
					end
				end
			end

			RESOURCES.each do |resource|
				["save", "like", "view", "dislike"].each do |taste_type|
					define_method "taste_#{resource}_#{TASTE_TYPES[taste_type][:past]}?" do |resource_id|
						if taste[resource]
							taste[resource][TASTE_TYPES[taste_type][:past]].include? resource_id.to_i
						else
							false
						end
					end
				end
			end

			RESOURCES.each do |resource|
				["save", "like", "view", "dislike"].each do |taste_type|
					define_method "taste_#{resource}_#{TASTE_TYPES[taste_type][:past]}" do
						taste.dig(resource, TASTE_TYPES[taste_type][:past])
					end
				end
			end

			private

		end

		module ClassMethods
		end


		private

	end
end
