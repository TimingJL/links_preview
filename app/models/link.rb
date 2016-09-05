class Link < ApplicationRecord
	searchkick highlight: [:title, :description]
	validates :link, presence: true	
end
