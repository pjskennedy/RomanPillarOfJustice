class Reaction < ActiveRecord::Base
  # This method associates the attribute ":avatar" with a file attachment
  has_attached_file :animation,
                    styles: {},
                    storage: :s3,
                    url: ':s3_domain_url',
                    s3_credentials: {
                      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
                    },
                    bucket: ENV['S3_BUCKET'],
                    path: '/:class/avatars/:id_:basename.:style.:extension'

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :animation, content_type: /\Aimage\/.*\Z/
end
