require 'capybara/poltergeist'
require 'spec_helper'
require 'dummy_app/dummy_app'

describe Napybara::Element do
  describe '#has_content?' do
    describe 'waits for Ajax events to complete before processing' do
      let(:session) do
        Capybara::Session.new(:poltergeist, DummyApp)
      end

      let(:test_page) do
        Napybara::DSL.build(session) do
          def element.visit!
            visit '/test.html'
          end

          form 'form' do
            notice_updater 'button.update'
            notice '.notice'
          end
        end
      end

      Steps do
        Given 'my page has an element A whose content changes a second after
          another element B is clicked' do
          test_page.visit!

          expect(test_page.form.notice).to have_content('Old content.')
          expect(test_page.form.notice).to have_no_content('New content.')
        end

        When 'I click on element B' do
          test_page.form.notice_updater.click
        end

        Then 'checking if element A has the new content should be true' do
          expect(test_page.form.notice).to have_content('New content.')
          expect(test_page.form.notice).to have_no_content('Old content.')
        end
      end
    end
  end
end
