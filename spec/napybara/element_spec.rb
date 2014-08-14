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
      page.finder(:form, '.some-form', '#form-{id}')

      object = OpenStruct.new(id: 1)

      expect(page.form(object).get['class']).to eq('some-form')
    end

    it 'allows the element to find a sub-element with a record method' do
      page = described_class.new(capybara_page)
      page.finder(:form, '.some-form', '#form-{name}')

      object = OpenStruct.new(name: 1)

      expect(page.form(object).get['class']).to eq('some-form')
    end

    it 'adds a method to get all the elements matching the selector' do
      page = described_class.new(capybara_page)
      page.finder(:button, 'button')

      expect(page.buttons.size).to eq(2)
      expect(page.buttons).to be_all do |element|
        element.get.tag_name == 'button'
      end
    end

    it 'adds child elements from the block to each element returned' do
      page = described_class.new(capybara_page)
      page.finder(:button, 'button') do |button|
        button.finder :img, 'img'
      end

      expect(page.buttons.size).to eq(2)
      expect(page.buttons[0].img.get.tag_name).to eq('img')
    end

    it 'adds a method to check if the element has a sub-element matching a record' do
      page = described_class.new(capybara_page)
      page.finder(:form, '.some-form', '#form-{id}')

      object = OpenStruct.new(id: 1)

      expect(page.has_form?(object)).to eq(true)
    end

    it 'adds a method to check if the element has no sub-element matching a record' do
      page = described_class.new(capybara_page)
      page.finder(:form, '.some-form', '#form-{id}')

      object = OpenStruct.new(id: 1)

      expect(page.has_no_form?(object)).to eq(false)
    end
  end

  describe "#selector" do
    it "can return the selector for a single element" do
      napybara_page = described_class.new(capybara_page) do |page|
        page.finder :form, '.some-form'
      end

      expect(napybara_page.form.selector).to eq('.some-form')
    end

    it "can return the selector for an element nested one layer" do
      napybara_page = described_class.new(capybara_page) do |page|
        page.finder :form, '.some-form' do |form|
          form.finder :some_button, '.some-button'
        end
      end

      expect(napybara_page.form.some_button.selector).to eq('.some-form .some-button')
    end

    it "can return the selector for an element nested more than one layer" do
      napybara_page = described_class.new(capybara_page) do |page|
        page.finder :form, '.some-form' do |form|
          form.finder :some_button, '.some-button' do |button|
            button.finder :img, 'img'
          end
        end
      end

      expect(napybara_page.form.some_button.img.selector)
        .to eq('.some-form .some-button img')
    end

    it "can return the selector for an element array" do
      napybara_page = described_class.new(capybara_page) do |page|
        page.finder :button, 'button'
      end

      expect(napybara_page.buttons.selector).to eq('button')
    end

    context "where the items of the element array are not adjacent" do
      let(:capybara_page) do
        Capybara.string <<-HTML
          <form class='some-form', id='form-1'>
            <button class='recognized-button some-button' />
            <button class='ignored-button' />
            <button class='recognized-button another-button' />
          </form>
        HTML
      end

      it "can return the selector of the ith item of an element array" do
        napybara_page = described_class.new(capybara_page) do |page|
          page.finder :button, '.recognized-button'
        end

        first_button = napybara_page.buttons[1]

        expect(first_button.selector).to eq('.recognized-button')

        expect(napybara_page.node.all(first_button.selector)[1]['class'])
          .to eq('recognized-button another-button')
      end
    end

    it "can return the selector of an child of an element array item" do
      napybara_page = described_class.new(capybara_page) do |page|
        page.finder :button, 'button' do |button|
          button.finder :image, 'img'
        end
      end

      expect(napybara_page.buttons[0].image.selector).to eq('button img')
    end
  end
end
