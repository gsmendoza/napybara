require 'napybara'

module Napybara
  class Element
    attr_reader :node
    alias_method :get, :node

    def initialize(node, &block)
      @node = node
      block.call(self) if block_given?
    end

    def finder(child_element_name, child_element_selector, record_selector = nil, &block)
      self.define_singleton_method(child_element_name) do |record = nil|
        selector = Selector.new(child_element_selector, record_selector, record)
        self.class.new(self.get.find(selector.to_s), &block)
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
        self.get.all(child_element_selector).map do |child_element|
          self.class.new(child_element, &block)
        end
      end
    end

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
end
