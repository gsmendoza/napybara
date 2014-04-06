require 'spec_helper'
require 'dummy_app/dummy_app'

describe 'Readme example:' do
  let(:capybara_page) do
    Capybara.string <<-HTML
      <html>
        <body>
          <ul class='messages-list'>
            <li class="message" id="message-1">Hello world!</li>
            <li class="message" id="message-2">Kamusta mundo!</li>
          </ul>
          <form class='new-message'>
            <div class="message-row" />
              <label for='message'>Message</label>
              <input id='message' type='text' name='message'>
            </div>
            <input type='submit' value='Send'/>
          </form>
      </html>
    HTML
  end

  Steps "Wrapping a page in a Napybara element" do
    Given "I have a capybara page" do
      capybara_page
    end

    When "I wrap that capybara page in a Napybara page" do
      @messages_page = Napybara::Element.new(capybara_page)
    end

    And "I call #get on the Napybara page" do
      @get_result = @messages_page.get
    end

    Then "I should get the capybara page" do
      expect(@get_result).to eq(capybara_page)
    end
  end

  Steps 'Find by selector' do
    Given "I have a capybara page" do
      capybara_page
    end

    When "I add a finder to the Napybara page wrapping the capybara page" do
      @messages_page = Napybara::Element.new(capybara_page) do |page|
        page.finder :form, 'form.new-message'
      end
    end

    Then "the finder should be able to find the element matching the selector" do

      expect(@messages_page.form.get['class']).to eq('new-message')
    end
  end

  Steps 'Find by object' do
    Given "I have a capybara page" do
      capybara_page
    end

    When "I add an object finder to the Napybara page wrapping the capybara page" do
      @messages_page = Napybara::Element.new(capybara_page) do |page|
        page.finder :message, '#message-'
      end
    end

    Then "the finder should be able to find the element matching a given object" do
      id = 1
      message = OpenStruct.new(id: id)
      expect(@messages_page.message(message).get['id']).to eq("message-#{id}")
    end
  end

  Steps 'Existence finders' do
    Given "I have a capybara page" do
      capybara_page
    end

    When "I add finders to the Napybara page wrapping the capybara page" do
      @messages_page = Napybara::Element.new(capybara_page) do |page|
        page.finder :form, 'form.new-message'
        page.finder :message, '#message-'
      end
    end

    Then "I can check for the existence of elements" do
      expect(@messages_page.has_form?).to be_true
      expect(@messages_page).to have_form

      some_message = OpenStruct.new(id: 1)
      expect(@messages_page.has_message?(some_message)).to be_true
      expect(@messages_page).to have_message(some_message)

      non_existent_message = OpenStruct.new(id: 3)
      expect(@messages_page.has_no_message?(non_existent_message)).to be_true
      expect(@messages_page).to have_no_message(non_existent_message)
    end
  end

  Steps 'Find all by selector' do
    Given "I have a capybara page" do
      capybara_page
    end

    When "I add a plain finder to the Napybara page wrapping the capybara page" do
      @messages_page = Napybara::Element.new(capybara_page) do |page|
        page.finder :message_item, '.message'
      end
    end

    Then "I should be able to find all the elements matching the selector with
      a plural version of the finder name" do

      expect(@messages_page.message_items[0].get.text).to eq("Hello world!")
      expect(@messages_page.message_items[1].get.text).to eq("Kamusta mundo!")
    end
  end

  Steps "Adding a custom method to the Napybara element" do
    Given "I have a capybara page" do
      capybara_page
    end

    When "I add a custom method to the Napybara element wrapping the capybara
      element" do
      @messages_page = Napybara::Element.new(capybara_page) do |page|
        def page.visit!
          @visited = true
        end

        def page.visited?
          !! @visited
        end
      end
    end

    Then "I can call the custom method on the Napybara element" do
      @messages_page.visit!
      expect(@messages_page).to be_visited
    end
  end

  Steps "Extending the Napybara element with a module" do
    Given "I have a capybara page" do
      capybara_page
    end

    When "I extend the Napybara element with a module" do
      module PageExtensions
        def visit!
          @visited = true
        end

        def visited?
          !! @visited
        end
      end

      @messages_page = Napybara::Element.new(capybara_page) do |page|
        page.extend PageExtensions
      end
    end

    Then "I can call the custom methods in the module on the Napybara element" do
      @messages_page.visit!
      expect(@messages_page).to be_visited
    end
  end
end