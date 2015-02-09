class User < ActiveRecord::Base
  devise :omniauthable, omniauth_providers: [:github]

  validates :github_username, presence: true, uniqueness: true

  has_many :memberships, class_name: 'TeamMembership'
  has_many :courses, through: :memberships

  has_many :solutions
  has_many :feedbacks

  serialize :github_data, JSON

  scope :admins,   -> { where admin: true  }
  scope :students, -> { where admin: false }

  def name
    super || github_username
  end

  def github_url
    "https://github.com/#{github_username}"
  end

  def active_course
    Course.find active_course_id if active_course_id
  end

  def octoclient
    if github_access_token
      @_octoclient ||= Octokit::Client.new access_token: github_access_token
    end
  end
end
