require 'napybara'

module Napybara
  class Element
    def initialize(capybara_element, &block)
      @capybara_element = capybara_element
      block.call(self) if block_given?
    end

    def find(child_element_name, child_element_selector, &block)
      self.define_singleton_method(child_element_name) do
        self.class.new(self.get.find(child_element_selector), &block)
      end
    end

    def get
      @capybara_element
    end
  end
end
