class User < ActiveRecord::Base
  devise :omniauthable, omniauth_providers: [:github]

  validates :github_username, presence: true, uniqueness: true

  has_many :memberships, class_name: 'TeamMembership'
  has_many :teams, through: :memberships

  has_many :solutions

  before_create do |user|
    user.email = "#{user.github_username}@github.com" unless user.email.present?
  end

  def name
    super || github_username
  end

  def github_url
    "https://github.com/#{github_username}"
  end

  def active_team
    Team.find active_team_id if active_team_id
  end
end
