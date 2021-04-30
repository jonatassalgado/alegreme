module JsonSerializer
  extend ActiveSupport::Concern
  class_methods do
    def serialize_json(fields)
      fields.each do |field|
        define_method("#{field}=") do |value|
          self[field] = value.is_a?(String) ? JSON.parse(value) : value
        end
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:include, JsonSerializer)
end