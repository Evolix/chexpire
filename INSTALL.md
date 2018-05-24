# Installation

## Configuration
After cloning this repository, you have to create and edit a few files from example files for your local development configuration :

- `config/database.yml`
- `config/chexpire.yml`
- `config/secrets.yml`

## Deployment

**staging** and **production** environments are preconfigured.

### Capistrano

If you want to use capistrano for deployment, create `config/deploy/config.yml` from the example file, and use the `to_staging` and/or `to_production` file.

As you created the config development files above, you'll have to do the same on the staging and production servers ( `shared/config/database.yml` etc…).
