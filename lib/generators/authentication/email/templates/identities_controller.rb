# frozen_string_literal: true

class <%= resource_pluralize.capitalize %>Controller < ApplicationController

  def new
    @<%= resource_name %> = <%= resource_name.classify %>.new
  end

  def create
    @<%= resource_name %> = <%= resource_name.classify %>.new <%= resource_name %>_params

    if @<%= resource_name %>.save
      warden.set_user(@<%= resource_name %>, scope: :<%=resource_name %>)
      redirect_to root_url, notice: t('.sign_up')
    else
      render :new
    end
  end

  private

  def <%= resource_name %>_params
    params.require(:<%= resource_name %>).permit :email, :password, :password_confirmation
  end
end
