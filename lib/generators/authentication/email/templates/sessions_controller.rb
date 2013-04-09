class SessionsController < ApplicationController
  def new
    <%= resource_name %> = <%= resource_name.classify %>.new
  end

  def create
    <%= resource_name %> = <%= resource_name.classify %>.authenticate params[:email], params[:password]

    if <%= resource_name %>
      session[:<%=resource_name %>_id] = <%= resource_name %>.id
      return redirect_to root_url, notice: t('.logged_in')
    end
    flash.now.alert = t('.invalid_credentials')
    render :new
  end

  def destroy
    session[:<%=resource_name %>_id] = nil
    redirect_to root_url, notice: t('.logged_out')
  end
end

