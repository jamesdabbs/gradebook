class SolutionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :receive_hook
  skip_before_action :authenticate_user!, only: :receive_hook
  skip_before_action :require_access_token!, only: :receive_hook

  def receive_hook
    request.body.rewind
    verify_signature request.body.read

    if issue = params[:issue]
      repo   = params[:repository][:full_name]
      number = issue[:number]
      status = issue[:state] == "closed" ? :closed : :assigned

      Rails.logger.info "Received issue hook: #{repo}##{number} - #{status}"

      Solution.where(
        number: issue[:number],
        repo:   params[:repository][:full_name]
      ).update_all(
        status:       status,
        completed_at: issue[:closed_at]
      )
    end

    head :ok
  end

  private

  def verify_signature payload_body
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV.fetch('GITHUB_WEBHOOK_SECRET'), payload_body)
    if Rack::Utils.secure_compare signature, request.env['HTTP_X_HUB_SIGNATURE']
      Rails.logger.debug "Validated webhook signature"
    else
      raise "Signatures didn't match!"
    end
  end
end
