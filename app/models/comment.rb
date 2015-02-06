class Comment < ActiveRecord::Base
  belongs_to :solution
  belongs_to :user

  validates_presence_of :remote_id, :solution, :user, :body
end
