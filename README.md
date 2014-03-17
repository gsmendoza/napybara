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
messages_page.form.message.text_field.set 'Hello World!'
messages_page.form.submit!
expect(messages_page.messages[0]).to have_content('Hello world!')
expect(messages_page.messages[1]).to have_content('Kamusta mundo!')
```

With Napybara, now they can! All you need is to define the structure of the page with Napybara's DSL:

```ruby
# spec/features/messages_spec.rb

:new_messsage_page) do
  Napybara::DSL.build(self) do
    all :messages, '.messages-list .message'

    find :form, 'form.new-message' do
      find :message, '.message' do
        find :text_field, 'input#message'
      end

      find :submit_button, 'input[type=submit]'
    end
  end
end
```

In the integration test above, the `self` in `Napybara::DSL.build(self)` points to the current test session. In Rails integration tests which include `Capybara::DSL`, `self` would already have access to `Capybara::DSL`'s methods.

 What about the custom `messages_page.visit!` and `form.submit!` methods? With Napybara, you can extend each element in the structure with the dsl's `extend_element` method. So if you want to add a `visit!` method to the `messages_page` element, you can write

```ruby
Napybara::DSL.build(self) do
  extend_element do
    def visit!
      visit '/messages/index'
    end
  end

  # ...
end
```

You can also reuse helpers by calling the `extend_element` with a module. For example, with `form.submit!`:

```ruby
module FormExtensions
  def submit!
    submit_button.click
  end
end

Napybara::DSL.build(self) do
  find :form, 'form.new-message' do
    extend_element FormExtensions
    # ...
  end
end
```

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
