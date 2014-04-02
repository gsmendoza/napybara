# Napybara

So you're writing an integration test for the following page:

```html
<html>
  <body>
    <ul class='messages-list'>
      <li class="message">Hello world!</li>
      <li class="message">Kamusta mundo!</li>
    </ul>
    <form class='new-message'>
      <div class="message" />
        <label for='message'>Message</label>
        <input id='message' type='text' name='message'>
      </div>
      <input type='submit' value='Send'/>
    </form>
</html>
```

Wouldn't it be nice if your test helpers followed the structure of the page?

```ruby
messages_page.visit!
messages_page.form.message.text_field.get.set 'Hello World!'
messages_page.form.submit!
expect(messages_page.messages[0]).to have_content('Hello world!')
expect(messages_page.messages[1]).to have_content('Kamusta mundo!')
```

With Napybara, now they can! All you need is to define the structure of the page with Napybara's DSL:

```ruby
# spec/features/messages_spec.rb

let(:new_message_page) do
  Napybara::Element.new(self) do |page|
    page.finder :message, '.messages-list .message'

    page.finder :form, 'form.new-message' do |form|
      form.finder :message, '.message' do |row|
        row.finder :text_field, 'input#message'
      end

      form.finder :submit_button, 'input[type=submit]'
    end
  end
end
```

In the integration test above, the `self` in `Napybara::Element.new(self)` points to the current test session. In Rails integration tests which include `Capybara::DSL`, `self` would already have access to `Capybara::DSL`'s methods.

 What about the custom `messages_page.visit!` and `form.submit!` methods? With Napybara, you can extend each element in the structure. So if you want to add a `visit!` method to the `messages_page` element, you can write

```ruby
Napybara::Element.new(self) do |page|
  def page.visit!
    get.visit '/messages/index'
  end

  # ...
end
```

`get` here points to the Capybara element that the Napybara element is wrapping.

You can also reuse helpers by extend the Napybara element with a module. For example, with `form.submit!`:

```ruby
module FormExtensions
  def submit!
    submit_button.get.click
  end
end

Napybara::Element.new(self) do |page|
  page.finder :form, 'form.new-message' do |form|
    form.extend FormExtensions
    # ...
  end
end
```

## Installation

Add this line to your application's Gemfile:

    gem 'Napybara'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install Napybara

## Contributing

1. Fork it ( http://github.com/<my-github-username>/Napybara/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
