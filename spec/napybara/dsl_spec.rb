require 'spec_helper'

describe Napybara::DSL do
  let(:capybara_page) do
    Capybara.string <<-HTML
      <form class='some-form'>
        <button class='some-button'></button>
      </form>
    HTML
  end

  describe '.build' do
    it 'returns an element delegating to the capybara_page' do
      element = described_class.build(capybara_page)
      expect(element).to be_a(Napybara::Element)
      expect(element.__getobj__).to eq(capybara_page)
    end

    it 'adds child elements from the block to the return element' do
      element = described_class.build(capybara_page) do
        form '.some-form'
      end

      expect(element.form['class']).to eq('some-form')
    end
  end

  describe '#find' do
    it 'adds a method to the element for finding the given selector' do
      dsl = described_class.new(capybara_page)
      dsl.find(:form, '.some-form')

      expect(dsl.element.form['class']).to eq('some-form')
    end

    it 'adds child elements from the block to the finder element' do
      dsl = described_class.new(capybara_page)
      dsl.find(:form, '.some-form') do
        find(:button, '.some-button')
      end

      expect(dsl.element.form.button['class']).to eq('some-button')
    end
  end
end
