require 'rubygems'
require 'active_support'
require "slack_500/version"

module Slack500

  class Error < StandardError;
  end

  ROOT_PATH = File.expand_path "../../", __FILE__

  module ::Rails
    class Application
      rake_tasks do
        Dir[File.join(ROOT_PATH, "/lib/tasks/", "**/*.rake")].each do |file|
          load file
        end
      end
    end
  end

  def self.setup
    yield self
  end

  mattr_accessor :pretext
  @@pretext = nil

  mattr_accessor :title
  @@title = nil

  mattr_accessor :color
  @@color = nil

  mattr_accessor :footer
  @@footer = nil

  mattr_accessor :webhook_url
  @@webhook_url = nil

  def self.post (request, exception, params = {})
    url = self.webhook_url
    begin
      uri = URI.parse(url)
    rescue
      Rails.logger.error '** Slack500:: invalid Webhook URL.'
      return
    end

    text = "#{request.method} #{request.url} (#{request.user_agent}) : #{request.query_parameters}\n#{exception.message}\n#{exception.backtrace.map {|s| s.gsub(Rails.root.to_s, '')}.join("\n")}"

    default_params = {
        pretext: self.pretext,
        title: self.title,
        color: self.color,
        footer: self.footer
    }

    attachments = default_params.merge(params)
    attachments[:text] = text
    attachments[:title] = "#{request.parameters[:controller]}##{request.parameters[:action]} - #{attachments[:title]}"

    params = {
        attachments: [attachments]
    }

    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.start do
        request = Net::HTTP::Post.new(uri.path)
        request.set_form_data(payload: params.to_json)
        http.request(request)
      end
    rescue => e
      Rails.logger.error "** Slack500:: #{e.full_message}."
    end
  end
end
