require 'securerandom'
# == Schema Information
#
# Table name: shortened_urls
#
#  id         :integer          not null, primary key
#  long_url   :string           not null
#  short_url  :string           not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ShortenedUrl < ApplicationRecord
  include SecureRandom
  validates :short_url, presence: true, uniqueness: true

  belongs_to :submitter,
             primary_key: :id,
             foreign_key: :user_id,
             class_name: :User

  has_many :visits,
           primary_key: :id,
           foreign_key: :url_id,
           class_name: :Visit

  has_many :visitors,
          #  -> { distinct },
           through: :visits,
           source: :visitor

  def self.random_code
    code = SecureRandom::urlsafe_base64

    while ShortenedUrl.exists?(short_url: code)
      code = SecureRandom::urlsafe_base64
    end

    code
  end

  def self.create!(user, long_url)
    ShortenedUrl.create(user_id: user.id, long_url: long_url, short_url: ShortenedUrl.random_code)
  end

  def num_clicks
    visitors.count
  end

  def num_uniques
    visits.select(:visitor_id).distinct.count
  end

  def num_recent_uniques
    visits.select(:visitor_id).distinct.where("visits.created_at > ?", 6.hours.ago).count
  end

  def self.time_test
    41.minutes.ago
  end
end
