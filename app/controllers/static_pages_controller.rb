class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :root
  skip_before_action :require_access_token!, only: :receive_hook

  def root
    if current_user
      if current_user.active_course
        redirect_to current_user.active_course
      else
        redirect_to courses_path
      end
    end
  end
end
