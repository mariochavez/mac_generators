# MacGenerators
This library has a set of generators to help with authentication on Rails
applications.

## Why not use an authentication gem?
There are options already for authentication on Rails applications, if you ok
with any of them, then you should use it.

- [Devise](https://github.com/plataformatec/devise)
- [Sorcery](https://github.com/NoamB/sorcery)
- [Clerance](https://github.com/thoughtbot/clearance)

My generators are very simple, they don't do anything else than help you to
handle authentication in your application. One generator is for email/password
authentication and the second one if for OAuth authentication with the help of
[Omniauth](https://github.com/intridea/omniauth).

Also both generators makes use of [Warden](https://github.com/hassox/warden) to
handle session on Rack, which allow you to mount
[Sinatra](https://github.com/bmizerany/sinatra) or
[Rack](https://github.com/chneukirchen/rack) applications and having them able
to hook up to current logged user.

Generators copy all files over your application, so if you want to customize or
learn how authentication was implemented, just open the files, inspect or
modify them. There is no need to fight, override or monkey patch libraries.

## Email/Password authentication
Generates files for email/password authentication, based on Rails has_secure_password
functionality.
It uses warden with a single database authentication strategy.

By default without parameters all code will be generated for a model Identity which
will be used for authetication purposes.

If you want to generate authentication for another model than Identity then pass it
as a first parameter.

Also if you want signup and signin templates to be haml files pass the option
--haml, otherwise they will be erb.

Example:

    rails generate authentication:email

This will create:

    app/controllers/identities_controller.rb
    app/controllers/sessions_controller.rb
    app/views/identities/new.html.erb
    app/views/sessions/new.html.erb
    app/models/identity.rb
    config/initializers/warden.rb
    lib/strategies/database_authentication.rb

And will modify:

    app/controllers/application_controller.rb
    config/locales/en.yml

And will add the following routes:

     route  get 'sign_up' => 'identities#new', as: :sign_up
     route  get 'log_in' => 'sessions#new', as: :log_in
     route  get 'log_out' => 'sessions#destroy', as: :log_out
     route  resource :identity, only: [:create, :new]
     route  resource :sessions, only: [:create, :new]

And finally will add to Gemfile:

     warden (~> 1.2.0)

Post generation steps are:

1. Run bundle command to install new gems.
2. Be sure that to have definition for root in your routes.
3. Run rake db:migrate to add your identities table.
4. Inspect warden initializer at config/initializers/warden.rb and update the failure_app if need it.
5. Inspect generated files and learn how authentication was implemented.

## OAuth authentication
Generates files for oauth authentication using omniauth.
It uses warden with a single oauth authentication strategy.

By default without parameters all code will be generated for a model Identity
which will be used for authetication purposes.

If you want to generate authentication for another model than Identity then pass it
as a first parameter.

Example:

    rails generate authentication:omniauth

This will create:

    app/controllers/sessions_controller.rb
    app/models/identity.rb
    config/initializers/warden.rb
    config/initializers/omniauth.rb
    config/initializers/authentication_domain.rb
    lib/strategies/oauth_authentication.rb

And will modify:

    app/controllers/application_controller.rb
    config/locales/en.yml

And will add the following routes:

    route  get 'auth/:provider/callback' => 'sessions#create', as: :log_in
    route  delete '/sessions/destroy' => 'sessions#destroy', as: :log_out

And finally will add to Gemfile:

    warden (~> 1.2.0)
    omniauth

Post generation steps are:

1. Add an omniauth provider gem like twitter, facebook, etc..
2. Modify config/initializers/omniauth.rb and setup your provider and your provider
credentials.
3. Run bundle command to install new gems.
4. If you want to restrict access to a specific email domain. Modify
config/initializers/authentication_domain.rb and add your allowed domain.
5. Inspect warden initializer at config/initializers/warden.rb and update the
failure_app.
6. Be sure that to have definition for root in your routes.
7. Run rake db:migrate to add your identities table.
8. Inspect generated files and learn how authentication was implemented.

## Why identity model and not user model by default?
Both generators were created of real code that I use, for me identity makes
more sense for authentication, this model does not carry anything else like
preferences, profile or anything else that is not related to identify the user,
so for it just makes sense to call this model identity.

#License
This project rocks and uses MIT-LICENSE.
