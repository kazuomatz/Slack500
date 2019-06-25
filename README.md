# Slack500

Slack500 is a gem that notifies exceptions raised by Rails to your Slack channel using incomming WebHooks URL.

The following items are displayed in the Slack message.

- http method
- Controller and Action
- Parameters
- User Agent
- Error Message
- Backtrace

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'slack_500'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install slack_500

Execute rake task to create configuration file.

    $ rake slack_500:config


and edit "/config/initializers/slack_500.rb"

```
require 'slack_500'
Slack500.setup do |config|
    # report pretext of slack message
    config.pretext = 'Slack Report Title'

    # report title of slack message
    config.title = 'Rendering 500 with exception.'

    # color of slack message
    config.color = '#FF0000'

    # footer text of slack message
    config.footer = 'via Slack 500 Report.'

    # WebHook URL
    # see https://slack.com/services/new/incoming-webhook
    config.webhook_url = "https://hooks.slack.com/services/xxxxxxxxx/xxxx"
end
```

## Usage

```
class ApplicationController < ActionController::Base

  if !Rails.env.production?
    rescue_from Exception, with: :rescue_500
  end

  :
  :

  def rescue_500(exception=nil)

    # Report Exception to Slack
    Slack500.post(request,exception)

    render 'error/500', status: :internal_server_error, layout: 'application'
    end

  :
  :

end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kazuomatz/slack_500. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Slack500 projects codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/slack_500/blob/master/CODE_OF_CONDUCT.md).
