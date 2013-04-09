class <%= resource_pluralize.capitalize %>Controller < ApplicationController

  def new
    @<%= resource_name %> = <%= resource_name.classify %>.new
  end

  def create
    @<%= resource_name %> = <%= resource_name.classify %>.new <%= resource_name %>_params

    if @<%= resource_name %>.save
      session[:<%=resource_name %>_id] = <%= resource_name %>.id
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
