# Capistrano::Strategy::JenkinsArtifact [![Build Status][travis-badge]][travis-url]

Capistrano 2 strategy that uses Jenkins' artifact as a distribution provider.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-strategy-jenkins_artifact'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-strategy-jenkins_artifact

## Usage

In your `Capfile` (`config/deploy.rb`, or `config/deploy/**/*.rb`):

```ruby
set :deploy_via, :jenkins_artifact
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aereal/capistrano-strategy-jenkins_artifact.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


[travis-url]: https://travis-ci.org/aereal/capistrano-strategy-jenkins_artifact
[travis-badge]: https://travis-ci.org/aereal/capistrano-strategy-jenkins_artifact.svg?branch=master
