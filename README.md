|[![Code Climate](https://codeclimate.com/github/gargath/biggles/badges/gpa.svg)](https://codeclimate.com/github/gargath/biggles)|[![Code Climate](https://codeclimate.com/github/gargath/biggles/badges/coverage.svg)](https://codeclimate.com/github/gargath/biggles)|[![Code Climate](https://codeclimate.com/github/gargath/biggles/badges/issue_count.svg)](https://codeclimate.com/github/gargath/biggles)|[![Build Status](https://travis-ci.org/gargath/biggles.svg?branch=master)](https://travis-ci.org/gargath/biggles)|
|---|---|---|---|


# Biggles

Biggles is a job scheduler based on ActiveRecord.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'biggles'
```

Biggles uses the concurrent-ruby gem for thread management.
If desired, you can install native C extensions for MRI Ruby by adding them to your Gemfile:

```ruby
gem 'concurrent-ruby-ext'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install biggles

## Usage

Before using biggles, you need to create the required database tables in your application's database.
If your application already uses `config/database.yml` for configuration, simply run
    
    $ biggles create_schema
    
You may also configura the database connection manually in `config/biggles.yml`.

You can interact with biggles Jobs like any other ActiveRecord object.
In order to execute the jobs, start the Biggles process using

    $ biggles start

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gargath/biggles. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [LGPL-3.0](https://opensource.org/licenses/LGPL-3.0).

## Code of Conduct

Everyone interacting in the Biggles project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/gargath/biggles/blob/master/CODE_OF_CONDUCT.md).
