# == Schema Information
#
# Table name: revisions
#
#  id                 :integer         not null, primary key
#  project_id         :integer
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  caption            :string(255)
#

class Revision < ActiveRecord::Base
  attr_accessible :image, :caption
  validates :project_id, presence: true
  validates :caption, length: { maximum: 140 }

  belongs_to :project
  has_many :feedbacks, dependent: :destroy

  default_scope order: 'revisions.created_at DESC'

  has_attached_file :image, {
    :storage => :s3,
    :bucket => ENV['FANCYLOOP_S3_BUCKET_NAME'],
    :s3_credentials => {
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    },
    :styles => {
      :large => "940x>",
      :thumb => "300x>",
    },
    :path => "revisions/images/:id/:style/:hash.:extension",
    :hash_secret => ENV['FANCYLOOP_HASH'],
  }

  validates_attachment :image, presence: true,
    :content_type => {
        :content_type => ["image/jpg", "image/x-png", "image/jpeg", "image/png"] },
        :size => { :in => 0..5.megabytes }
end
