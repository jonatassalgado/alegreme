class Numeric
	def numeric?
		Float(self) != nil rescue false
	end
end
