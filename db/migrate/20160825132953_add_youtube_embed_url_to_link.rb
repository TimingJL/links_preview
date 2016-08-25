class AddYoutubeEmbedUrlToLink < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :youtube_embed_url, :string
  end
end
