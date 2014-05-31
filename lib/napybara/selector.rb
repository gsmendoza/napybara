module Napybara
  class Selector < Struct.new(:child_element_selector, :record_selector, :record)
    METHOD_NAME_REGEX = /\{(\w+)\}/
    def method_name
      record_selector.match(METHOD_NAME_REGEX)[1]
    end

    def record_id
      record && record.public_send(method_name)
    end

    def to_s
      if record
        record_selector.gsub(METHOD_NAME_REGEX, record_id.to_s)
      else
        child_element_selector
      end
    end
  end
end
