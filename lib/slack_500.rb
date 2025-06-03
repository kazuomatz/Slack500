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

    bullet = ':black_small_square:'
    text = "#{exception.message}\n\n"

    text += "#{bullet}*Request*\n*#{request.method}* #{request.url}\n\n"
    text += "#{bullet}*User Agent*\n#{request.user_agent}\n\n"
    text += "#{bullet}*IP*\n#{request.remote_ip}\n\n"
    text += "#{bullet}*Query*\n#{request.query_parameters}\n\n" unless request.query_parameters.empty?

    request.body.rewind
    body_text = request.body.read

    begin
      if body_text.present?
        body = JSON.parse(body_text)
      end
    rescue => e
      if body_text.present?
        body_params = {}
        body_text.split('&').each do |param|
          kv = param.split("=")
          if kv.length == 2
            if kv[0].downcase.index('token').present? || kv[0].downcase.index('password').present?
              body_params[URI.decode_www_form_component(kv[0])] = '[** FILTERED **]'
            elsif kv[0] != 'utf8'
              body_params[URI.decode_www_form_component(kv[0])] = truncate(URI.decode_www_form_component(kv[1]).force_encoding('UTF-8'),100)
            end
          end
        end
        if body_params.empty?
          body = body_text
        else
          body = body_params
        end
      end
    end

    text += "#{bullet}*Body*\n#{body}\n\n" unless body.nil?
    text += "#{bullet}*Backtrace*\n#{exception.backtrace.map {|s| "`#{s.gsub('`', '').gsub("'", '').gsub(Rails.root.to_s, '')}`"}.join("\n")}"
    text = text.force_encoding('UTF-8')
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

  private
  def self.truncate(string, max)
    string.length > max ? "#{string[0...max]}..." : string
  end

end
