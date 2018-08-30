# == Route Map
#
#                    Prefix Verb   URI Pattern                                                                              Controller#Action
#  check_check_notification DELETE /checks/:check_id/check_notifications/:id(.:format)                                      check_notifications#destroy
#                    checks GET    /checks(.:format)                                                                        checks#index
#                           POST   /checks(.:format)                                                                        checks#create
#                 new_check GET    /checks/new(.:format)                                                                    checks#new
#                edit_check GET    /checks/:id/edit(.:format)                                                               checks#edit
#                     check PATCH  /checks/:id(.:format)                                                                    checks#update
#                           PUT    /checks/:id(.:format)                                                                    checks#update
#                           DELETE /checks/:id(.:format)                                                                    checks#destroy
#             notifications GET    /notifications(.:format)                                                                 notifications#index
#                           POST   /notifications(.:format)                                                                 notifications#create
#          new_notification GET    /notifications/new(.:format)                                                             notifications#new
#         edit_notification GET    /notifications/:id/edit(.:format)                                                        notifications#edit
#              notification PATCH  /notifications/:id(.:format)                                                             notifications#update
#                           PUT    /notifications/:id(.:format)                                                             notifications#update
#                           DELETE /notifications/:id(.:format)                                                             notifications#destroy
#          new_user_session GET    /users/sign_in(.:format)                                                                 devise/sessions#new
#              user_session POST   /users/sign_in(.:format)                                                                 devise/sessions#create
#      destroy_user_session DELETE /users/sign_out(.:format)                                                                devise/sessions#destroy
#         new_user_password GET    /users/password/new(.:format)                                                            devise/passwords#new
#        edit_user_password GET    /users/password/edit(.:format)                                                           devise/passwords#edit
#             user_password PATCH  /users/password(.:format)                                                                devise/passwords#update
#                           PUT    /users/password(.:format)                                                                devise/passwords#update
#                           POST   /users/password(.:format)                                                                devise/passwords#create
#  cancel_user_registration GET    /users/cancel(.:format)                                                                  devise/registrations#cancel
#     new_user_registration GET    /users/sign_up(.:format)                                                                 devise/registrations#new
#    edit_user_registration GET    /users/edit(.:format)                                                                    devise/registrations#edit
#         user_registration PATCH  /users(.:format)                                                                         devise/registrations#update
#                           PUT    /users(.:format)                                                                         devise/registrations#update
#                           DELETE /users(.:format)                                                                         devise/registrations#destroy
#                           POST   /users(.:format)                                                                         devise/registrations#create
#     new_user_confirmation GET    /users/confirmation/new(.:format)                                                        devise/confirmations#new
#         user_confirmation GET    /users/confirmation(.:format)                                                            devise/confirmations#show
#                           POST   /users/confirmation(.:format)                                                            devise/confirmations#create
#                      root GET    /                                                                                        pages#home
#         letter_opener_web        /letter_opener                                                                           LetterOpenerWeb::Engine
#        rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
# rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#        rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
# update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#      rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create
#
# Routes for LetterOpenerWeb::Engine:
# clear_letters DELETE /clear(.:format)                 letter_opener_web/letters#clear
# delete_letter DELETE /:id(.:format)                   letter_opener_web/letters#destroy
#       letters GET    /                                letter_opener_web/letters#index
#        letter GET    /:id(/:style)(.:format)          letter_opener_web/letters#show
#               GET    /:id/attachments/:file(.:format) letter_opener_web/letters#attachment

# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

# In order to update the route map above,
# run `bundle exec annotate -r` after modifying this file
Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :checks, except: [:show] do
    resources :check_notifications, only: [:destroy]
  end

  resources :notifications, except: [:show]

  devise_for :users
  root to: "pages#home"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
