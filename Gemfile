source "https://rubygems.org"

group :development, :test do
  # This is here because gemspec doesn't support require: false
  gem 'coveralls', :require => false
  gem 'pacto', :git => 'git@github.com:thoughtworks/pacto.git', :branch => 'non_webmock'
end

gemspec
