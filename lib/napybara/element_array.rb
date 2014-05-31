module Napybara
  class ElementArray < Array
    def initialize(elements, parent, selector_string = '')
      @parent = parent
      @selector_string = selector_string
      super(elements)
    end

    def selector
      parent_selector = @parent.try(:selector)
      parent_selector ? "#{@parent.selector} #{@selector_string}" : @selector_string
    end
  end
end
