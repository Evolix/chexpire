# Installation

## Rails configuration

After cloning this repository, you have to create and edit a few files from example files for your local development configuration :

- `config/database.yml`
- `config/chexpire.yml`
- `config/secrets.yml`

### Database

You can customize `config/database.yml` for your needs, but by default, Rails is looking for a `chexpire_development` database on localhost.

### Dependencies

Execute `# bundle install` to install Ruby dependencies.
Execute `# yarn install` to install Javascript dependencies.

### Tests

The test suite can be run with `# bundle exec rails test`.
This will also generate a code coverage report in `coverage/index.html`.

With `# bundle exec guard` your test suite is run once and then once for each file you change and save. Take a look at https://guardgem.org for more information.

### Local execution

If you want to start the Rails application manually, with a simple Puma configuration, you have to execute `# bundle exec rails server`.

## Deployment

**staging** and **production** environments are preconfigured.

### Capistrano

If you want to use capistrano for deployment, create `config/deploy/config.yml` from the example file, and use the `to_staging` and/or `to_production` file.

As you created the config development files above, you'll have to do the same on the staging and production servers ( `shared/config/database.yml` etc…).
