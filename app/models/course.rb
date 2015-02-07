class Course < ActiveRecord::Base
  belongs_to :instructor, class_name: 'User'
  belongs_to :team

  validates_presence_of :title, :instructor, :team, :start_date
end
