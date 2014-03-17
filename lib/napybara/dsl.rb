module Napybara
  class DSL < Struct.new(:element)
    def self.build(capybara_node, &block)
      @element = capybara_node
      capybara_node.tap do |element|
        dsl_instance = new(element)
        dsl_instance.instance_eval(&block) if block_given?
      end
    end

    def find(child_element_name, child_element_selector, &block)
      element.define_singleton_method(child_element_name) do
        Napybara::DSL.build(self.find(child_element_selector), &block)
      end
    end
  end
end
