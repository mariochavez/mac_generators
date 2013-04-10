class <%= resource_name.classify %> < ActiveRecord::Base

  class << self
    def find_identity(uid, provider)
      where(uid: uid, provider: provider).first
    end
  end

end
