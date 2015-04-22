class Namespace < ActiveRecord::Base

  has_many :repositories
  belongs_to :team
  validates :name, presence: true

end
