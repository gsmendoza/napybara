require 'napybara'

module Napybara
  class FinderMethodsAppender
    attr_reader :element, :child_element_name, :child_element_selector,
      :optional_args, :block

    def initialize(
      element, child_element_name, child_element_selector, optional_args, block)

      @element, @child_element_name, @child_element_selector, @optional_args, @block =
        element, child_element_name, child_element_selector, optional_args, block
    end

    def record_selector
      return if optional_args.empty?
      return if !optional_args[0].is_a?(String)

      optional_args[0]
    end

    def capybara_options
      return {} if optional_args.empty?
      return {} if !optional_args[0].is_a?(Hash)

      optional_args[0]
    end

    def execute
      define_child_element_method
      define_has_child_element_method
      define_has_no_child_element_method
      define_child_elements_method
    end

    private

    def define_child_element_method
      appender = self

      element.define_singleton_method(child_element_name) do |record = nil|
        selector = Selector.new(
          appender.child_element_selector,
          appender.record_selector,
          record)

        selector_string = selector.to_s

        capybara_element =
          self.get.find(selector_string, appender.capybara_options)

        self.class.new(capybara_element, self, selector_string, &appender.block)
      end
    end

    def define_has_child_element_method
      appender = self

      element.define_singleton_method("has_#{child_element_name}?") do |record = nil|
        selector = Selector.new(
          appender.child_element_selector,
          appender.record_selector, record)

        self.get.has_css?(selector.to_s)
      end
    end

    def define_has_no_child_element_method
      appender = self

      element.define_singleton_method("has_no_#{child_element_name}?") do |record = nil|
        selector = Selector.new(
          appender.child_element_selector,
          appender.record_selector,
          record)

        self.get.has_no_css?(selector.to_s)
      end
    end

    def define_child_elements_method
      appender = self

      element.define_singleton_method(child_element_name.to_s.pluralize) do
        elements = self.get.all(appender.child_element_selector).map do |child_element|
          self.class.new(
            child_element, self, appender.child_element_selector, &appender.block)
        end

        ElementArray.new(elements, self, appender.child_element_selector)
      end
    end
  end
end
