require_relative "lib/chobble_forms/version"

Gem::Specification.new do |spec|
  spec.name = "chobble-forms"
  spec.version = ChobbleForms::VERSION
  spec.authors = ["Chobble.com"]
  spec.email = ["hello@chobble.com"]

  spec.summary = "Semantic Rails forms with strict i18n"
  spec.description = "A Rails engine for semantic HTML forms with enforced internationalization. Provides reusable form components with built-in accessibility, validation states, and strict i18n requirements."
  spec.homepage = "https://github.com/chobbledotcom/chobble-forms"
  spec.license = "AGPL-3.0-or-later"
  spec.required_ruby_version = ">= 3.2.0", "< 3.5"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir["{app,lib,views}/**/*", "README.md", "LICENSE", "CHANGELOG.md"]

  spec.add_dependency "rails", ">= 8.0.0"
  spec.add_dependency "sorbet-runtime", "~> 0.5"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "sorbet", "~> 0.5"
  spec.add_development_dependency "tapioca", "~> 0.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec-rails", "~> 6.0"
  spec.add_development_dependency "capybara", "~> 3.0"
  spec.add_development_dependency "standard", "~> 1.0"
  spec.add_development_dependency "simplecov", "~> 0.21"
end
