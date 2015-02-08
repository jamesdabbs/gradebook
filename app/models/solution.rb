class Solution < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user

  has_many :comments

  validates :repo, presence: true
  validates :number, presence: true, uniqueness: { scope: :repo }

  scope :incomplete, -> { where "completed_at IS NULL" }
  scope :needing_review, -> {
    where(reviewed: false).where "completed_at IS NOT NULL" }
  scope :reviewed, -> { where reviewed: true }

  def closed?
    completed_at.present?
  end
  def mark_closed! time
    update! completed_at: time
  end

  def mark_reviewed!
    update! reviewed: true
  end

  def issue_url
    "https://github.com/#{repo}/issues/#{number}"
  end

  def remote octoclient
    @_remote ||= octoclient.issue repo, number
  end

  def pull_comments! octoclient
    remote(octoclient).rels[:comments].get.data.each do |rc|
      comments.where(remote_id: rc.id).first_or_create! do |c|
        c.user       = User.where(github_username: rc.user.login).first!
        c.body       = rc.body
        c.created_at = rc.created_at
      end
    end
  end

  def author_comments
    comments.where user: user
  end

  def admin_comments
    comments.where user: User.admin
  end

  def store_solution_url!
    return if solution_url.present?
    corpus = author_comments.pluck(:body).join "\n"
    link = URI.extract(corpus).first
    update_attributes! solution_url: link if link
  end

  # Sync should be safe to run on each issue state change
  #   (and idempotent, assuming no updates on Github)
  def sync! octoclient=nil
    octoclient ||= assignment.course.admin.octoclient

    pull_comments! octoclient
    store_solution_url!
    remote = remote octoclient

    if !closed? && remote.state == "closed"
      mark_closed! remote.closed_at
    end

    if !reviewed? && admin_comments.any?
      mark_reviewed!
    end
  end
end
