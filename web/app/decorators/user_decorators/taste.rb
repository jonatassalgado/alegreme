module UserDecorators
	module Taste

		TASTE_TYPES = [:save, :like, :view, :dislike]

		TASTE_ACTIONS = {
				save:    {
						add:    :save,
						remove: :unsave
				},
				like:    {
						add:    :like,
						remove: :unlike
				},
				dislike: {
						add:    :dislike,
						remove: :undislike
				}
		}

		TASTE_TEXTS = {
				save:    {
						add:    "Salvar",
						remove: "Salvo"
				},
				like:    {
						add:    "Curtir",
						remove: "Curtido"
				},
				dislike: {
						add:    "Não Gostei",
						remove: "Desfazer"
				}
		}

		TASTE_VERBS = {
				save:      {
						past:   "saved",
						plural: "saves"
				},
				unsave:    {
						past:   "saved",
						plural: "saves"
				},
				like:      {
						past:   "liked",
						plural: "likes"
				},
				unlike:    {
						past:   "liked",
						plural: "likes"
				},
				view:      {
						past:   "viewed",
						plural: "views"
				},
				dislike:   {
						past:   "disliked",
						plural: "dislikes"
				},
				undislike: {
						past:   "disliked",
						plural: "dislikes"
				}
		}

		RESOURCES = [:events, :movies]

		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end


		module InstanceMethods

			def tasted?(resource, taste_type)
				self.public_send("taste_#{resource.class.base_class.name.tableize}_#{TASTE_VERBS[taste_type.to_sym][:past]}?", resource.id)
			end

			RESOURCES.each do |resource|
				TASTE_TYPES.each do |taste_type|
					define_method "#{TASTE_VERBS[taste_type][:past]}_#{resource}" do
						if self && self.public_send("taste_#{resource}_#{TASTE_VERBS[taste_type][:past]}").present?
							resource.to_s.classify.constantize.public_send("#{TASTE_VERBS[taste_type][:past]}_by_user", self)
						else
							resource.to_s.classify.constantize.none
						end
					end
				end
			end

			RESOURCES.each do |resource|
				TASTE_TYPES.each do |taste_type|
					define_method "#{TASTE_VERBS[taste_type][:past]}_#{resource}_ids" do
						if self && !self.public_send("taste_#{resource}_#{TASTE_VERBS[taste_type][:past]}").empty?
							if resource == :events
								Event.public_send("#{TASTE_VERBS[taste_type][:past]}_by_user", self).active.order_by_date.uniq.pluck(:id)
							elsif resource == :movies
								Movie.public_send("#{TASTE_VERBS[taste_type][:past]}_by_user", self).order_by_date.uniq.pluck(:id)
							end
						else
							resource.to_s.classify.constantize.none
						end
					end
				end
			end

			RESOURCES.each do |resource|
				TASTE_TYPES.each do |taste_type|
					define_method "taste_#{resource}_#{taste_type}" do |_instance|
						begin
							_resource = resource.to_s
							instance  = _instance.is_a?(ApplicationRecord) ? _instance : resource.to_s.classify.constantize.find(_instance.to_i)

							ActiveRecord::Base.transaction do
								instance.entries["#{TASTE_VERBS[taste_type][:past]}_by"]      |= [id]
								instance.entries["total_#{TASTE_VERBS[taste_type][:plural]}"] += 1

								validate_taste_existence resource
								taste[_resource][TASTE_VERBS[taste_type][:past]]              |= [instance.id]
								taste[_resource]["total_#{TASTE_VERBS[taste_type][:plural]}"] += 1
								taste[_resource]['updated_at']                                = DateTime.now

								instance.save && save
							end
						rescue ActiveRecord::RecordInvalid
							puts 'Não foi possível salvar sua ação (ERRO 7813)!'
						else
							if taste_type == :save && resource == :events
								UpdateUserEventsSuggestionsJob.perform_later(self.id)
							end

							return taste_type
						end
					end
				end
			end

			RESOURCES.each do |resource|
				TASTE_ACTIONS.map { |key, value| value[:remove] }.each do |taste_type|
					define_method "taste_#{resource}_#{taste_type}" do |_instance|
						begin
							_resource = resource.to_s
							instance  = _instance.is_a?(ApplicationRecord) ? _instance : resource.to_s.classify.constantize.find(_instance.to_i)

							ActiveRecord::Base.transaction do
								instance.entries["#{TASTE_VERBS[taste_type][:past]}_by"].delete id
								instance.entries["total_#{TASTE_VERBS[taste_type][:plural]}"] -= 1

								validate_taste_existence resource
								taste[_resource][TASTE_VERBS[taste_type][:past]].delete instance.id
								taste[_resource]["total_#{TASTE_VERBS[taste_type][:plural]}"] -= 1
								taste[_resource]['updated_at']                                = DateTime.now

								instance.save && save
							end
						rescue ActiveRecord::RecordInvalid
							puts 'Não foi possível salvar sua ação (ERRO 7813)!'
							return false
						else
							if taste_type == :unsave && resource == :events
								UpdateUserEventsSuggestionsJob.perform_later(self.id)
							end

							return taste_type
						end
					end
				end
			end

			RESOURCES.each do |resource|
				TASTE_TYPES.each do |taste_type|
					define_method "taste_#{resource}_#{TASTE_VERBS[taste_type][:past]}?" do |resource_id|
						_resource = resource.to_s
						if taste[_resource]
							taste[_resource][TASTE_VERBS[taste_type][:past]].include? resource_id.to_i
						else
							false
						end
					end
				end
			end

			RESOURCES.each do |resource|
				TASTE_TYPES.each do |taste_type|
					define_method "taste_#{resource}_#{TASTE_VERBS[taste_type][:past]}" do
						_resource = resource.to_s
						taste.dig(_resource, TASTE_VERBS[taste_type][:past])
					end
				end
			end

			private

		end

		module ClassMethods
			def taste_action(taste_type, action = :add)
				TASTE_ACTIONS[taste_type.to_sym][action]
			end

			def taste_verbs(taste_type, tense)
				TASTE_VERBS[taste_type.to_sym][tense]
			end

			def taste_texts(taste_type, action = :add)
				TASTE_TEXTS[taste_type.to_sym][action]
			end
		end


		private

	end
end
