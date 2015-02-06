class Assignment < ActiveRecord::Base
  belongs_to :team
  has_many :solutions, dependent: :destroy

  validates :gist_id, presence: true, uniqueness: true
  validates :title, presence: true

  default_scope -> { order due_at: :asc }

  after_initialize do
    tomorrow = 1.day.from_now
    self.due_at ||= DateTime.new tomorrow.year, tomorrow.month, tomorrow.day, 9, 0, 0, "EST"
  end

  validate :found_gist_body
  def found_gist_body
    errors.add :gist_id, "not found" if body.nil?
  end

  # TODO: add after_update hook to sync issues
  def sync_from_gist! octoclient
    name, file = octoclient.gist(gist_id).files.first
    self.body  = file.content
    self.title = name.to_s.gsub(/\.md$/, '').gsub('_', ' ').titleize
  rescue Octokit::NotFound => e
    self.body = nil
  end

  def as_issue
    "_Due on #{ApplicationHelper.format_datetime due_at}_\n#{body}"
  end

  def check! octoclient
    solutions.find_each { |s| s.sync! octoclient }
    update_attribute :checked_at, Time.now
  end

  def sync_issues!
    solutions.each do |solution|
      raise NotImplemented # $octoclient.update_issue ... if different?
    end
  end
end
