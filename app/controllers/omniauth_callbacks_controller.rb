class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    data = request.env["omniauth.auth"]
    info = data["info"]

    user = User.where(github_username: info["nickname"]).first_or_create! do |u|
      token  = data["credentials"]["token"]
      client = Octokit::Client.new access_token: token
      admin  = client.organizations.find { |o| o.login == "theironyard" }.present?

      u.email                 = info["email"]
      u.name                  = info["name"]
      u.admin                 = admin
      u.github_data           = data
      u.github_access_token ||= token
    end

    # For legacy users
    user.update_attributes github_data: data if user.github_data.nil?

    sign_in_and_redirect user, event: :authentication
    set_flash_message(:notice, :success, kind: "Github") if is_navigational_format?
  end
end
