require 'spec_helper'

describe Napybara::FinderMethodsAppender do
  let(:block) { nil }
  let(:capybara_options) { { visible: false } }
  let(:child_element_name) { 'some_element' }
  let(:child_element_selector) { '.some_element' }
  let(:element) { VerifiedDouble.instance_of(Napybara::Element) }
  let(:optional_args) { [] }
  let(:record_selector) { '#some_element_{id}' }

  subject do
    described_class.new(
      element,
      child_element_name,
      child_element_selector,
      optional_args,
      block
    )
  end

  describe "#record_selector" do
    context "when there is no optional arg" do
      before do
        expect(optional_args).to be_empty
      end

      it "should be nil" do
        expect(subject.record_selector).to be_nil
      end
    end

    context "when there is one optional arg and it is a String" do
      let(:optional_args) { [record_selector] }

      it "should be the string" do
        expect(subject.record_selector).to eq(record_selector)
      end
    end

    context "when there is one optional arg and it is a Hash" do
      let(:optional_args) { [capybara_options] }

      it "should be the nil" do
        expect(subject.record_selector).to be_nil
      end
    end

    context "when there are multiple optional args" do
      let(:optional_args) { [record_selector, capybara_options] }

      it "should be the first argument" do
        expect(subject.record_selector).to eq(record_selector)
      end
    end
  end

  describe "#capybara_options" do
    context "when there is no optional arg" do
      before do
        expect(optional_args).to be_empty
      end

      it "should be {}" do
        expect(subject.capybara_options).to eq({})
      end
    end

    context "when there is one optional arg and it is a String" do
      let(:optional_args) { [record_selector] }

      it "should be the {}" do
        expect(subject.capybara_options).to eq({})
      end
    end

    context "when there is one optional arg and it is a hash" do
      let(:optional_args) { [capybara_options] }

      it "should be the hash" do
        expect(subject.capybara_options).to eq(capybara_options)
      end
    end

    context "when there are multiple optional args" do
      let(:optional_args) { [record_selector, capybara_options] }

      it "should be the last argument" do
        expect(subject.capybara_options).to eq(capybara_options)
      end
    end
  end
end
