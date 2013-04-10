class <%= resource_name.classify %> < ActiveRecord::Base
  has_secure_password validations: true

  validates :email, presence: true, uniqueness: true
  validates :password_confirmation, presence: true, if: -> r { r.password.present? }
end
