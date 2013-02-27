# Crummy Test

## Introduction

This is a test application for [Crummy][crummy], and also a good place where you can see it in action.

  [crummy]: http://github.com/zachinglis/crummy

## Usage

I recommend you to use [RVM][rvm] in order to keep this application gemset distinct from the gem one. Here we use a full Rails stack, which is not true when developping the gem. I you only want to see Crummy in action, you might not care about that. Anyways RVM is not required, but if you use it you'll find an `.rvmrc` file for each context: `example/.rvmrc` and `.rvmrc` respectively for the example app and the gem. Using them is easy and only requires to take care of the directory from where you `bundle install`: if from `example`, you'll update the app bundle, else the gem bundle.

  [rvm]: https://rvm.io

To quickly start the example app:

```bash
# Enter the example directory and trust the .rvmrc file
cd crummy/example

# Install the bundle
bundle install
# Create the database
bundle exec rake db:schema:load
bundle exec rake db:seed
# Create the test database
bundle exec rake db:test:clone

# Get the tests green
bundle exec rake

# Start the server
rails server
```

Your app waits for you at [http://localhost:3000](http://localhost:3000).

* * *

I hope this makes the example application a better place to test the gem.
