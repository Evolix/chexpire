# Installation

## Requirements

Chexpire requires :
* Ruby > 2.5.4 and Bundler
* NodeJS and Yarn
* MySQL or MariaDB

We are usually running Chexpire on typical POSIX servers like :
- Linux Debian 9, Ruby 2.5.4, NodeJS 8.11 and MariaDB 10.1
- macOS High Sierra, Ruby 2.5.4, NodeJS 10.2.1 and MariaDB 10.2

It probably works on any system that supports Ruby >2.3, NodeJS >6 and MySQL >5.5. Feel free to report any unexpected incompatibilities.

If you use rbenv, chruby or RVM, you can set your prefered Ruby version in the `.ruby-version` file at the root of the project.

If you are familiar with Ansible, you can use our [Ansible roles](http://forge.evolix.org/projects/ansible-roles) to easily install the requirements : rbenv, mysql, nodejs. Add this to your playbook :

```
[…]
roles:
  - mysql
  - { role: rbenv, username: "{{ ansible_user }}", rbenv_ruby_version: "2.5.4" }
  - { role: nodejs, nodejs_install_yarn: yes }
[…]
```

> NB: the rbenv `username` variable points to the user that you want to install rbenv for. If you use this user for the SSH connection of Ansible, you can leave the `{{ ansible_user }}` value.

If you want to do manual installations, you can use our Wiki documentations for [rbenv](https://github.com/rbenv/rbenv/#installation), [NodeJS](https://wiki.evolix.org/HowtoNodeJS#installation), [Yarn](https://wiki.evolix.org/HowtoNodeJS#yarn) and [MariaDB](https://wiki.evolix.org/HowtoMySQL#installation).

## Dependencies

Execute `# bundle install` to install Ruby gems (including Rails itself).

Execute `# yarn install` to install Javascript/NodeJS packages.

Depending on what is already installed on your OS or not, you might need to install a few system packages to be able to have everything working.

### libsodium

To use elliptic curve SSH keys, we need to have `libsodium` and its headers.
* on Debian : `# apt install libsodium-dev`.
* on macOS with Homebrew : `# brew install libsodium`.


## Rails configuration

After cloning this repository, you have to create and edit a few files for your local development/test configuration. Theses files will be ignored by git.

### Database configuration

Create the file if missing : `cp config/database.example.yml config/database.yml`. If you change the settings in the `defaults` section it applies to the `development` and `test` sections. More information is available at "guides.rubyonrails.org":https://guides.rubyonrails.org/configuring.html#configuring-a-database

Note that on Debian 9 with MariaDB, the database socket is at `/var/run/mysqld/mysqld.sock`, which is not the default in the configuration file.

### Rails secrets

Create the file if missing : `cp config/secrets.example.yml config/secrets.yml`. You have to run the command `bundle exec rails secret` and copy/paste the output in the `secret_key_base` settings of the `development` and `test` sections

### Chexpire configuration

Create the file if missing : `cp config/chexpire.example.yml config/chexpire.yml`. Set at least the `mailer_default_from` and `host` variables. See other configuration overridable in `config/chexpire.defaults.yml`.

## Database

You need databases for development and tests. You can create them like this (once connected to you MySQL server) :

```
MariaDB [none]> CREATE DATABASE `chexpire_development`;
MariaDB [none]> CREATE DATABASE `chexpire_test`;
```

If you don't want to use the default `root` MySQL user with no password, you can create users :

```
MariaDB [none]> GRANT ALL PRIVILEGES ON `chexpire_development%`.* TO `chexpire_development`@localhost IDENTIFIED BY 'MY_PASSWORD_FOR_DEV';
MariaDB [none]> GRANT ALL PRIVILEGES ON `chexpire_test%`.* TO `chexpire_test`@localhost IDENTIFIED BY 'MY_PASSWORD_FOR_TEST';
MariaDB [none]> FLUSH PRIVILEGES;
```

You must run the migrations with `# bundle exec rails db:migrate` (for the default environment – development) and `# bundle exec rails db:migrate RAILS_ENV=test` (for the test environment).

## Tests

Some tests require Selenium with ChromeDriver. On Debian, you can install it with `$ apt install chromedriver`.

The test suite can be run with `# bundle exec rails test`.

This will also generate a code coverage report in `coverage/index.html`.

With `# bundle exec guard` your test suite is run completely a first time, then once for each file you change and save. Take a look at https://guardgem.org for more information.

To execute Rubocop (the style-guide linter for Ruby), run `# bundle exec rubocop`.

## Local execution

If you want to start the Rails application manually, with a simple Puma configuration, you have to execute `# bundle exec rails server`. You will be able to open http://127.0.0.1:3000 in your browser and see Chexpire in action.

## Deployment

**staging** and **production** environments are preconfigured. You can use any of them or add more if you want.

### Capistrano

You can deploy Chexpire however you want, but we've pre-configured the repository to use Capistrano.

If you want to use it, you need to create `cp config/deploy/config.example.yml config/deploy/config.yml` and customize the settings.

You can use the `script/to_staging` and/or `script/to_production` scripts.
* with `to_staging` you deploy the current commit to the staging server ;
* with `to_production` you deploy the `master` branch to production.

On the remote servers – where the application will be deployed – you have to copy the configuration files just as you've just did for your development setup. The files has to go in the `shared/config/` directory, relative to your `deploy_to` path. They will be symlinked to the proper destination by Capistrano.
