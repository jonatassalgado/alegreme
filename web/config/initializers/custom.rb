class String
	def parameterize_with_accents
		self.underscore.gsub(" ", "-")
	end

	def numeric?
		Float(self) != nil rescue false
	end

	def boolean?
		['true', 'false'].include?(self)
	end

	def to_boolean
		ActiveRecord::Type::Boolean.new.cast(self)
	end
end

class NilClass
	def boolean?
		false
	end

	def to_boolean
		false
	end
end

class TrueClass
	def boolean?
		true
	end

	def to_boolean
		true
	end

	def to_i
		1
	end
end

class FalseClass
	def boolean?
		true
	end

	def to_boolean
		false
	end

	def to_i
		0
	end
end

class Integer
	def boolean?
		false
	end

	def to_boolean
		to_s.to_boolean
	end
end

class Numeric
	def boolean?
		false
	end

	def numeric?
		Float(self) != nil rescue false
	end
end
