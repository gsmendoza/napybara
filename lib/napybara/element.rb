require 'napybara'

module Napybara
  class Element
    attr_reader :capybara_element
    alias_method :get, :capybara_element

    def initialize(capybara_element, &block)
      @capybara_element = capybara_element
      block.call(self) if block_given?
    end

    def all(child_element_name, child_element_selector, &block)
      self.define_singleton_method(child_element_name) do
        self.get.all(child_element_selector).map do |child_element|
          self.class.new(child_element, &block)
        end
      end
    end

    def finder(child_element_name, child_element_selector, method_name = :id, &block)
      self.define_singleton_method(child_element_name) do |record = nil|
        selector =
          if record
            record_id = record && record.public_send(method_name)
            "#{child_element_selector}#{record_id}"
          else
            child_element_selector
          end

        self.class.new(self.get.find(selector), &block)
      end
    end
  end
end
