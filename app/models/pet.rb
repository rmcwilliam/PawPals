class Pet < ActiveRecord::Base
  belongs_to :user
  has_many :pet_check_ins, dependent: :destroy
  has_many :pet_notices, dependent: :destroy

  validates_presence_of :name, :breed, :age, :description


  has_attached_file :avatar, :default_url => "https://s3-us-west-2.amazonaws.com/production-pawpals/pets/avatars/000/000/default_image.jpg",
   :default_style => :medium,:styles => {thumb: '124x155>', small: '200x200>', medium: '400x500', mobile: '800x1000>'}
  validates_with AttachmentSizeValidator, attributes: :avatar, less_than: 1.megabytes
  validates_attachment_content_type :avatar, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  

  def sync_from_api
    api = AdafruitApi.new
    last_checkin = self.pet_check_ins.last(5)
    checkins = api.get_coordinates(last_checkin)
    checkins.each do |checkin|
      self.pet_check_ins.create(longitude: checkin[:long], latitude: checkin[:lat],
                                adafruit_created_at: checkin[:time], adafruit_id: checkin[:id])
    end
    if self.pet_check_ins.exists?
      result = self.pet_check_ins.order(adafruit_created_at: :desc).first
      adafruit_time_stamp = result.adafruit_created_at
      self.update(last_checkin_time: adafruit_time_stamp)
    else
    end
  end
end





    
   

