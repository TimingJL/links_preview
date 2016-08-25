class AddYoutubeIdToLink < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :youtube_id, :string
  end
end
