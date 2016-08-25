class LinksController < ApplicationController
    before_action :find_link, only: [:show, :edit, :update, :destroy]

    def index
        @links = Link.all.order("created_at DESC")
    end

    def show
    end

    def new
        @link = Link.new
    end

    def create
        @link = Link.new(link_params)
 
        require 'link_thumbnailer'
        object = LinkThumbnailer.generate(@link.link)

        @link.title = object.title
        @link.favicon = object.favicon
        @link.description = object.description
        @link.image = object.images.first.src.to_s

        if @link.save
            redirect_to @link
        else
            render 'new'
        end
    end

    def edit
    end

    def update 		 	
	    if @link.update(link_params)
			require 'link_thumbnailer'
			object = LinkThumbnailer.generate(@link.link)

			@link.title = object.title
			@link.favicon = object.favicon
			@link.description = object.description
			@link.image = object.images.first.src.to_s
			@link.save	    
				
	        redirect_to @link
	    else
	        render 'edit'
	    end    	
    end

	def destroy
	    @link.destroy
	    redirect_to links_path
	end

    private

    def find_link
        @link = Link.find(params[:id])
    end

    def link_params
        params.require(:link).permit(:link)
    end
end
