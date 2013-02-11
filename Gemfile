source :rubygems

gemspec

group :test do
  gem 'rspec', '~> 2.11.0'
  gem 'rr',    '~> 1.0.4'

  platform :mri_18 do
    gem 'rcov'
  end

  platform :mri_19 do
    gem 'simplecov'
    gem 'launchy'
  end
end
