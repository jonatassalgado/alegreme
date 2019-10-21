module UserDecorators
	module Requirements

		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		module InstanceMethods
			def need_to_finish_swipable?
				!personas_assortment_finished?
			end
		end

		module ClassMethods
		end


		private
	end
end