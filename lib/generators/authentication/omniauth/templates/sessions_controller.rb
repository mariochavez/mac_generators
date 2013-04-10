class SessionsController < ApplicationController
  def create
    warden.authenticate!(scope: :<%= resource_name %>)
    redirect_to root_url, notice: t('.logged_in')
  end

  def destroy
    warden.logout(:<%=resource_name %>)
    redirect_to root_url, notice: t('.logged_out')
  end
end

