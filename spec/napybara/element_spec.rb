require 'spec_helper'

describe Napybara::Element do
  let(:capybara_page) do
    Capybara.string <<-HTML
      <form class='some-form', id='form-1'>
        <button class='some-button'>
          <img />
        </button>

        <button class='another-button'>
          <img />
        </button>
      </form>
    HTML
  end

  describe '#new' do
    it 'returns the element' do
      element = described_class.new(capybara_page)
      expect(element).to be_a(Napybara::Element)
      expect(element.get).to eq(capybara_page)
    end

    it 'adds child elements from the block to the return element' do
      element = described_class.new(capybara_page) do |page|
        page.finder :form, '.some-form'
      end

      expect(element.form.get['class']).to eq('some-form')
    end
  end

  describe '#finder' do
    it 'adds a method to the element for finding the given selector' do
      page = described_class.new(capybara_page)
      page.finder(:form, '.some-form')

      expect(page.form.get['class']).to eq('some-form')
    end

    it 'adds child elements from the block to the finder element' do
      page = described_class.new(capybara_page)
      page.finder(:form, '.some-form') do |form|
        form.finder(:button, '.some-button')
      end

      expect(page.form.button.get['class']).to eq('some-button')
    end

    it 'allows the element to find a sub-element with an id' do
      page = described_class.new(capybara_page)
      page.finder(:form, '#form-')

      object = OpenStruct.new(id: 1)

      expect(page.form(object).get['class']).to eq('some-form')
    end

    it 'allows the element to find a sub-element with a record method' do
      page = described_class.new(capybara_page)
      page.finder(:form, '#form-', :name)

      object = OpenStruct.new(name: 1)

      expect(page.form(object).get['class']).to eq('some-form')
    end

    it 'adds a method to get all the elements matching the selector' do
      page = described_class.new(capybara_page)
      page.finder(:button, 'button')

      expect(page.buttons).to have(2).elements
      expect(page.buttons).to be_all do |element|
        element.get.tag_name == 'button'
      end
    end

    it 'adds child elements from the block to each element returned' do
      page = described_class.new(capybara_page)
      page.finder(:button, 'button') do |button|
        button.finder :img, 'img'
      end

      expect(page.buttons).to have(2).elements
      expect(page.buttons[0].img.get.tag_name).to eq('img')
    end
  end
end
