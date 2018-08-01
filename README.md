# Chexpire [![Build Status](https://travis-ci.org/Evolix/chexpire.svg?branch=master)](https://travis-ci.org/Evolix/chexpire)

A web application to help check for domain or SSL/TLS certificate expirations.

![Shakespeare quote: « An SSL error has occured and a secure connection to the server cannot be made. »](app/assets/images/shakespeare_quote_ssl.png)


## How-To Add a new check kind

TL;DR:

- write a job for executing and updating a check instance of your kind and use `CheckLogger` to log important event during a check execution.
- Write a `CheckProcessor` class to perform theses jobs at regular interval.
- For each notification channel, implement the code that notify the user when the date will expires soon or when there are recurrent failures.


Start by appending a new kind into the `Check` model at the `enum :kind` line.

### Write a job and the check execution

The job takes a `Check` instance as an argument and is responsible for performing the check and updating the following dates fields for the check instance:

  - mandatory: `last_run_at`, immediately when the execution is starting
  - mandatory: `domain_expires_at`
  - mandatory: `last_success_at`, when no problems have occured during the verification and fields have been updated
  - optional: `domain_created_at`, `domain_updated_at`, when the kind of check allows them

The code architecture is up to you and can vary depending on the check, but most of time you should write a service which will execute something and parse the response. Then you'll return a simple response object which responds to methods used for updating check fields in the job.

Look at the SSL and Domain implementations for examples.


### CheckLogger

This is not currently required, but you should use the `CheckLogger` class to emit log events at important steps of a check execution (especially when error occurs): this can help in case of problems. A single `CheckLogger` instance is attached to a check execution and fill a `CheckLog` model instance with various contents. Looks into the code to see supported events.

### CheckProcessor

A `processor` is responsible for executing checks at regular interval, selectively or not, depending of your needs.
Basically, it performs your job for all relevant checks.

Create a processor dedicated for your check kind. The class should include the `CheckProcessor` module and respond to the following methods :

- `configuration_key`: returns the key name of configuration in chexpire configuration file. For instance: `checks_domain`
- `scope`: returns the checks scope used by each resolver. Generally, this should be the base scope defined into the `CheckProcessor` module, filtered by your check kind (ie: `base_scope.your_kind`)
- `resolvers`: returns an array of methods which returns checks to execute. Allows conditional checks depending of various checks criterias such as far known expiry date, failing checks etc…
Looks into the `CheckProcessor` for available resolvers methods or write your own. use `resolve_all` resolver if you want execute all of your check at each execution.
- `process`: must execute or enqueue your job for a given check as argument. Note: because the processor is called into a task, and to take profit of a interval configuration parameter, it's better to execute the job synchronously in this method.

### Configuration

Each check kind can have configuration. Looks for other checks configuration for examples, such as `checks_domain` configuration in `config/chexpire.example.yml` file.

### Schedule a task

Write a task in `lib/tasks/checks.rake` under the namespaces `checks:sync_dates` and invoke the `sync_dates` method of your processor. Schedule to run it periodically in `config/schedule.rb`, or list the task in the `all` alias which is the default processor scheduler.

### Notifier

Finally, you have to write the way the checks will be notified to theirs users. For each notifier channel (email, …) you need to write two notifications :

- expires_soon
- recurrent_failures

First, add your checks kinds and these notifications definitions in the base class for notifier: `app/services/notifier/channels/base.rb` : in the notify method, for your new check kind, a specific method will be called in each notifier. For example, in the email channel, a specific mailer action is called for each couple (check kin, notification kind).
Then, in each notifier class, implements the details of this method. If you want to ignore a notification for a given channel, simply write the method and do nothing.
