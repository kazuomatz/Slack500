
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "slack_500/version"

Gem::Specification.new do |spec|
  spec.name          = "slack_500"
  spec.version       = Slack500::VERSION
  spec.authors       = ["Kazuo Matsunaga"]
  spec.email         = ["getlasterror@gmail.com"]

  spec.summary       = %q{Post Rails Exceptions to your Slack channel.}
  spec.description   = %q{Slack500 is a gem that notifies exceptions raised by Rails to your Slack channel using incomming WebHooks URL.}
  spec.homepage      = "https://github.com/kazuomatz/Slack500"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  s.required_ruby_version = '>= 2.3.0'

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_runtime_dependency "rails",">= 5.0"
end
