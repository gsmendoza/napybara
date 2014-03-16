# Napybara

So you're writing an integration test for the following page:

```html
<html>
  <body>
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
new_message_page.visit!
new_message_page.form.message.text_field.set 'Hello World!'
new_message_page.form.submit!
```

With Napybara, now they can! All you need is to define the structure of the page with Napybara's simply awesome DSL:

```ruby
# spec/features/messages_spec.rb

let(:new_message_page) do
  Napybara::DSL.build(self) do
    form 'form.new-message' do
      message '.message' do
        text_field 'input#message'
      end

      submit_button 'input[type=submit]'
    end
  end
end
```

In the integration test above, the `self` in `Napybara::DSL.build(self)` points to the current test session. In Rails integration tests which include `Capybara::DSL`, `self` would already have access to `Capybara::DSL`'s methods.

What about the custom `new_message_page.visit!` and `form.submit!` methods? With Napybara, you can access each element in the structure through the dsl's `element` method. So if you want to add a `visit!` method to the `new_message_page element`, you can write

```ruby
Napybara::DSL.build(self) do
  def element.visit!
    visit '/messages/new'
  end

  # ...
end
```

You can also reuse helpers by extending the `element` with a module. For example, with `form.submit!`:

```ruby
module FormExtensions
  def submit!
    submit_button.click
  end
end

Napybara::DSL.build(self) do
  form 'form.new-message' do
    element.extend FormExtensions
    # ...
  end
end
```

The `element` method just points to the element object that was created, so you can extend the object with the magic of plain Ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'napybara'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install napybara

## Contributing

1. Fork it ( http://github.com/<my-github-username>/napybara/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
