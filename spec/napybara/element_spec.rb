require 'spec_helper'

describe Napybara::Element do
  let(:capybara_page) do
    Capybara.string <<-HTML
      <form class='some-form'>
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
        page.find :form, '.some-form'
      end

      expect(element.form.get['class']).to eq('some-form')
    end
  end

  describe '#find' do
    it 'adds a method to the element for finding the given selector' do
      page = described_class.new(capybara_page)
      page.find(:form, '.some-form')

      expect(page.form.get['class']).to eq('some-form')
    end

    it 'adds child elements from the block to the finder element' do
      page = described_class.new(capybara_page)
      page.find(:form, '.some-form') do |form|
        form.find(:button, '.some-button')
      end

      expect(page.form.button.get['class']).to eq('some-button')
    end
  end

  describe '#all' do
    it 'adds a method to get all the elements matching the selector' do
      page = described_class.new(capybara_page)
      page.all(:buttons, 'button')

      expect(page.buttons).to have(2).elements
      expect(page.buttons).to be_all do |element|
        element.get.tag_name == 'button'
      end
    end

    it 'adds child elements from the block to each element returned' do
      page = described_class.new(capybara_page)
      page.all(:buttons, 'button') do |button|
        button.find :img, 'img'
      end

      expect(page.buttons).to have(2).elements
      expect(page.buttons[0].img.get.tag_name).to eq('img')
    end
  end
end
