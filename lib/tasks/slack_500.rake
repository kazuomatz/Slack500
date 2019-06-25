namespace :slack_500 do
  desc 'configuration slack_500'
  task :config do
    file = File.join(Rails.root,'config','initializers','slack_500.rb')
    if File.exists?(file)
      puts "#{file} esxits. overwrite? (y/n)"
      s = STDIN.getc
      exit unless s[0].downcase == 'y'
    end
    File.open(file,'w') do |file|
      file.puts("require 'Slack500'")
      file.puts("\nSlack500.setup do |config|")

      file.puts("\n    # report pretext of slack message")
      file.puts("    config.pretext = 'Slack Report Title'")

      file.puts("\n    # report title of slack message")
      file.puts("    config.title = 'Rendering 500 with exception.'")

      file.puts("\n    # color of slack message")
      file.puts("    config.color = '#FF0000'")

      file.puts("\n    # footer text of slack message")
      file.puts("    config.footer = 'via Slack 500 Report.'")

      file.puts("\n    # WebHook URL")
      file.puts("    # see https://slack.com/services/new/incoming-webhook")
      file.puts("    config.webhook_url = '(Your Slack WebHook URL)https://hooks.slack.com/services/xxxxxxxxx/xxxx'")

      file.puts("\nend")
    end
    puts "Slack500:: you need edit #{file}."
  end
end
