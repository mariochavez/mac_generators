class <%= resource_name.classify %> < ActiveRecord::Base
  attr_accessor :password
  before_save :encrypt_password

  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :email
  validates_uniqueness_of :email

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def self.authenticate(email, password)
    <%= resource_name %> = where(email: email).first

    if <%= resource_name %> && <%= resource_name %>.password_hash == BCrypt::Engine.hash_secret(password, <%= resource_name %>.password_salt)
      <%= resource_name %>
    else
      nil
    end
  end
end
