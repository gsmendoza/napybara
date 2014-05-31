require 'napybara'

module Napybara
  class Element
    attr_reader :node, :parent, :selector_string

    alias_method :get, :node

    def initialize(node, parent = nil, selector_string = nil, &block)
      @node = node
      @parent = parent
      @selector_string = selector_string

      block.call(self) if block_given?
    end

    def finder(child_element_name, child_element_selector, record_selector = nil, &block)
      self.define_singleton_method(child_element_name) do |record = nil|
        selector = Selector.new(child_element_selector, record_selector, record)
        selector_string = selector.to_s

        self.class.new(self.get.find(selector_string), self, selector_string, &block)
      end

      self.define_singleton_method("has_#{child_element_name}?") do |record = nil|
        selector = Selector.new(child_element_selector, record_selector, record)
        self.get.has_css?(selector.to_s)
      end

      self.define_singleton_method("has_no_#{child_element_name}?") do |record = nil|
        selector = Selector.new(child_element_selector, record_selector, record)
        self.get.has_no_css?(selector.to_s)
      end

      self.define_singleton_method(child_element_name.to_s.pluralize) do
        elements = self.get.all(child_element_selector)
          .map.with_index do |child_element, i|

          self.class.new(child_element, self, child_element_selector, &block)
        end

        ElementArray.new(elements, self, child_element_selector)
      end
    end

    def selector
      parent_selector = parent.try(:selector)
      parent_selector ? "#{parent_selector} #{selector_string}" : selector_string
    end
  end
end
