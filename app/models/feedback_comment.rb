class FeedbackComment < ActiveRecord::Base
  belongs_to :commenter, class_name: "User"
  belongs_to :feedback

  COOL, MEH, NOT_COOL = 1,2,3

  validates_presence_of :feedback, :body
  validates_inclusion_of :score, in: [COOL, MEH, NOT_COOL]
  validates :commenter, presence: true, uniqueness: { scope: :feedback}
end
