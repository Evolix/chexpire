# Installation

## Requirements

Chexpire requires :
* Ruby 2.5.1 and Bundler
* NodeJS and Yarn
* MySQL or MariaDB

We are usually running Chexpire on typical POSIX servers like :
- Linux Debian 9, Ruby 2.5.1, NodeJS 8.11 and MariaDB 10.1
- macOS High Sierra, Ruby 2.5.1, NodeJS 10.2.1 and MariaDB 10.2

It probably works on any system that supports Ruby >2.3, NodeJS >6 and MySQL >5.5. Feel free to report any unexpected incompatibilities.

If you are familiar with Ansible, you can use our [Ansible roles](http://forge.evolix.org/projects/ansible-roles) to easily install the requirements : rbenv, mysql, nodejs. Add this to your playbook :

```
[…]
roles:
  - mysql
  - { role: rbenv, username: "{{ ansible_user }}", rbenv_ruby_version: "2.5.1" }
  - { role: nodejs, nodejs_install_yarn: yes }
[…]
```

> NB: the Rbenv `username` variable points to the user that you want to install Rbenv for. If you use this user for the SSH connection of Ansible, you can leave the `{{ ansible_user }}` value.

If you want to do manual installations, you can use our Wiki documentations for [Rbenv](https://github.com/rbenv/rbenv/#installation), [NodeJS](https://wiki.evolix.org/HowtoNodeJS#installation), [Yarn](https://wiki.evolix.org/HowtoNodeJS#yarn) and [MariaDB](https://wiki.evolix.org/HowtoMySQL#installation).

## Dependencies

Execute `# bundle install` to install Ruby gems (including Rails itself).

Execute `# yarn install` to install Javascript/NodeJS packages.

Depending on what is already installed on your OS or not, you might need to install a few system packages to be able to have everything working.

### libsodium

To use elliptic curve SSH keys, we need to have `libsodium` and its headers.
* on Debian : `# apt install libsodium-dev`.
* on macOS with Homebrew : `# brew install libsodium`.


## Rails configuration

After cloning this repository, you have to create and edit a few files from example files, for your local development configuration :

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

Don't forget to adapt the settings in `config/database.yml` accordingly.
Also, on Debian 9 with MariaDB, the database socket is at `/var/run/mysqld/mysqld.sock`, which is not the default in the configuration file.

You must run the migrations with `# bundle exec rails db:migrate` (for the default environment – development) and `# bundle exec rails db:migrate RAILS_ENV=test` (for the test environment).

## Tests

The test suite can be run with `# bundle exec rails test`.

This will also generate a code coverage report in `coverage/index.html`.

With `# bundle exec guard` your test suite is run completely a first time, then once for each file you change and save. Take a look at https://guardgem.org for more information.

To execute Rubocop (the style-guide linter for Ruby), run `# bundle exec rubocop`.

## Local execution

If you want to start the Rails application manually, with a simple Puma configuration, you have to execute `# bundle exec rails server`. You will be able to open http://127.0.0.1:3000 in your browser and see Chexpire in action.

## Deployment

**staging** and **production** environments are preconfigured. You can use any of them or add more if you want.

### Capistrano

If you want to use capistrano for deployment, yout need to create `config/deploy/config.yml` from the example file, and use the `script/to_staging` and/or `script/to_production` scripts.

The same way you've created the config files for development, you'll have to do the same on the staging and production servers in the `shared/config/` directory,relative to your `deploy_to` path.
