# Napybara

So you're writing an integration test for the following page:

```html
<html>
  <body>
    <ul class='message-list'>
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
```

Wouldn't it be nice if your test helpers followed the page's structure?

```ruby
messages_page.visit!

messages_page.form.message_row.text_field.get.set 'Hello World!'
messages_page.form.submit!

expect(messages_page.message(Message.find(1))).to have_content('Hello world!')
expect(messages_page.message(Message.find(2))).to have_content('Kamusta mundo!')

expect(messages_page.messages[0]).to have_content('Hello world!')
expect(messages_page.messages[1]).to have_content('Kamusta mundo!')
```

With Napybara, now you can!

## Napybara::Element.new and #get

First off, let's wrap the Capybara session in a Napybara element:

```ruby
let(:messages_page) do
  Napybara::Element.new(self)
end
```

In Rails integration tests which use Capybara, `self` is usually the Capybara session.

You can get the Capybara element wrapped by the Napybara element with
`Napybara::Element#get`:

```ruby
expect(messages_page.get).to eq(self)
```

## Finding by selector

You can add finders to the Napybara page with `Napybara::Element#finder`:

```ruby
let(:messages_page) do
  Napybara::Element.new(self) do |page|
    page.finder :form, 'form.new-message'
  end
end

# ...

expect(messages_page.form.get['class']).to eq('new-message')
```

## Finding by object

In order to find an element representing a particular ruby object, you need to
add a separate selector which incorporates the ruby object's id:

```ruby
let(:messages_page) do
  Napybara::Element.new(self) do |page|
    page.finder :message, '.message', '#message-{id}'
  end
end

let(:some_message) do
  Message.find(1)
end

# ...

expect(messages_page.message(some_message).get['id'])
  .to eq("message-#{some_message.id}")

```

In the above example, the `message` finder looks for an element matching the
given selector (`#message-{id}`) with `some_message`'s id (`1`). So it ends up
looking for "#message-1".

If the ruby object is identified by a method other than the object's id, you can replace `{id}` with the method e.g. `{name}`, `{to_s}`.


## Checking if an element exists

`Napybara::Element#finder` also adds `has_` and `has_no_` methods to the element.
With the Napybara elements above, you can call:

```
expect(messages_page.has_form?).to be_true
expect(messages_page).to have_form

expect(messages_page.has_message?(some_message)).to be_true
expect(messages_page).to have_message(some_message)

non_existent_message = Message.find(3)
expect(messages_page.has_no_message?(non_existent_message)).to be_true
expect(messages_page).to have_no_message(non_existent_message)
```

Due to the magic that Capybara does when finding elements in a Ajaxified page,
it's recommended to call `expect(element).to have_no_...` instead of
`expect(element).to_not have...`, since the former relies on Capybara's Ajax-
friendly `has_no_css?` method.

## Finding all elements matching a selector

Finally, `Napybara::Element#finder` adds a pluralized version of the finder. For example,

```ruby
let(:messages_page) do
  Napybara::Element.new(self) do |page|
    page.finder :message, '.message'
  end
end

# ...

expect(messages_page.messages[0].get.text).to eq("Hello world!")
expect(messages_page.messages[1].get.text).to eq("Kamusta mundo!")
```

Napybara uses ActiveSupport to get the plural version of the finder name.

## Adding custom methods to a Napybara element

You can add new methods to a Napybara element with plain Ruby:

```ruby
let(:messages_page) do
  Napybara::Element.new(self) do |page|
    def page.visit!
      get.visit get.messages_path
    end
  end
end

# ...

messages_page.visit!
```

## Extending a Napybara element with a module

Adding the same methods to multiple Napybara elements? You can share the methods in a module:

```ruby
module PageExtensions
  def visit!
    get.visit get.messages_path
    @visited = true
  end

  def visited?
    !! @visited
  end
end

let(:messages_page) do
  Napybara::Element.new(capybara_page) do |page|
    page.extend PageExtensions
  end
end

# ...

messages_page.visit!
expect(messages_page).to be_visited
```

## Extending a Napybara element with a module with finders

And what if you want to share a module with finders? Again, with plain Ruby:

```
module IsAForm
  def submit!
    submit_button.get.click
  end

  def self.add_to(form)
    form.extend self
    form.finder :submit_button, 'input[type=submit]'
  end
end

# ...

page.finder :form, 'form.new-message' do |form|
  IsAForm.add_to(form)
end
```

It may not sexy, but it gets the job done :)

## Putting it all together

Oh yeah, the "N" in Napybara stands for nesting. Here's how you can define the
helpers at the start of this README:

```ruby

module PageExtensions
  def visit!
    get.visit get.messages_path
    @visited = true
  end

  def visited?
    !! @visited
  end
end

module IsAForm
  def submit!
    submit_button.get.click
  end

  def self.add_to(form)
    form.extend self
    form.finder :submit_button, 'input[type=submit]'
  end
end

let(:messages_page) do
  Napybara::Element.new(capybara_page) do |page|
    page.extend PageExtensions

    page.finder :form, 'form.new-message' do |form|
      IsAForm.add_to form

      form.finder :message_row, '.message-row' do |row|
        row.finder :text_field, 'input[type=text]'
      end
    end

    page.finder :message, '.message-list .message', '#message-{id}'
  end
end
```

## Installation

```
$ gem install Napybara
```

## Contributing

I'm still looking for ways to improve Napybara's DSL. If you have an idea, a
pull request would be awesome :)
