require 'napybara'

module Napybara
  class Element
    attr_reader :capybara_element
    alias_method :get, :capybara_element

    def initialize(capybara_element, &block)
      @capybara_element = capybara_element
      block.call(self) if block_given?
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

      self.define_singleton_method("has_#{child_element_name}?") do |record|
        record_id = record && record.public_send(method_name)
        selector = "#{child_element_selector}#{record_id}"
        self.get.has_css?(selector)
      end

      self.define_singleton_method("has_no_#{child_element_name}?") do |record|
        record_id = record && record.public_send(method_name)
        selector = "#{child_element_selector}#{record_id}"
        self.get.has_no_css?(selector)
      end

      self.define_singleton_method(child_element_name.to_s.pluralize) do
        self.get.all(child_element_selector).map do |child_element|
          self.class.new(child_element, &block)
        end
      end
    end
  end
end
