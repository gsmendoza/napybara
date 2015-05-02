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

    def finder(child_element_name, child_element_selector, *optional_args, &block)
      appender = FinderMethodsAppender.new(
        self, child_element_name, child_element_selector, optional_args, block)

      appender.execute
    end

    def inspect
      %(#<Napybara::Element selector="#{selector}">)
    end

    def root
      parent ? parent.parent : self
    end

    def selector
      parent_selector = parent.try(:selector)
      parent_selector ? "#{parent_selector} #{selector_string}" : selector_string
    end
  end
end
