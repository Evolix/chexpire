# Installation

## Requirements

Chexpire requires :
* Ruby 2.5.1 and Bundler
* NodeJS and Yarn
* MySQL or MariaDB

We are currently using Chexpire on :
- Linux Debian 9, Ruby 2.5.1, NodeJS 8.11 and MariaDB 10.1
- macOS High Sierra, Ruby 2.5.1, NodeJS 10.2.1 and MariaDB 10.2

It probably works on any system that support Ruby >2.3, NodeJS >6 and MySQL >5.5.

You can use our [Ansible roles](http://forge.evolix.org/projects/ansible-roles) to easily install the requirements : rbenv, mysql, nodejs. Example :

```
[…]
roles:
  - mysql
  - { role: rbenv, username: "{{ ansible_user }}", rbenv_ruby_version: "2.5.1" }
  - { role: nodejs, nodejs_install_yarn: yes }
[…]
```

NB: the Rbenv `username` variable points to the user that you want to install Rbenv for. If you use this user for the SSH connection of Ansible, you can leave the `{{ ansible_user }}` value.

If you prefer, you can install [Rbenv](https://github.com/rbenv/rbenv/#installation), [NodeJS](https://wiki.evolix.org/HowtoNodeJS#installation), [Yarn](https://wiki.evolix.org/HowtoNodeJS#yarn) and [MariaDB](https://wiki.evolix.org/HowtoMySQL#installation) manually.

## Dependencies

Execute `# bundle install` to install Ruby dependencies (including Rails itself).
Execute `# yarn install` to install Javascript dependencies.

## Rails configuration

After cloning this repository, you have to create and edit a few files from example files for your local development configuration :

- `config/database.yml`
- `config/chexpire.yml`
- `config/secrets.yml`

## Database

You need databases for development and tests. You can create them like this (once connected to you MySQL server) :

```
MariaDB [none]> CREATE DATABASE `chexpire_development`;
MariaDB [none]> CREATE DATABASE `chexpire_test`;
```

If you don't want to use the default `root` MySQL user with no password, you can create users :

```
MariaDB [none]> GRANT ALL PRIVILEGES ON `chexpire_development`.* TO `chexpire_development`@localhost IDENTIFIED BY 'MY_PASSWORD_FOR_DEV';
MariaDB [none]> GRANT ALL PRIVILEGES ON `chexpire_test`.* TO `chexpire_test`@localhost IDENTIFIED BY 'MY_PASSWORD_FOR_TEST';
MariaDB [none]> FLUSH PRIVILEGES;
```

Don't forget to do the same for the test database and to adapt the settings in `config/database.yml` accordingly.
Also, on Debian 9 with MariaDB, the database socket is at `/var/run/mysqld/mysqld.sock`, which is not the default in the configuration file.

You must run the migrations with `# bundle exec rails db:migrate` (for development) and `# bundle exec rails db:migrate RAILS_ENV=test` (for test).

## Tests

The test suite can be run with `# bundle exec rails test`.
This will also generate a code coverage report in `coverage/index.html`.

With `# bundle exec guard` your test suite is run completely a first time, then once for each file you change and save. Take a look at https://guardgem.org for more information.

## Local execution

If you want to start the Rails application manually, with a simple Puma configuration, you have to execute `# bundle exec rails server`.

## Deployment

**staging** and **production** environments are preconfigured.

### Capistrano

If you want to use capistrano for deployment, create `config/deploy/config.yml` from the example file, and use the `to_staging` and/or `to_production` file.

As you created the config development files above, you'll have to do the same on the staging and production servers ( `shared/config/database.yml` etc…).
