Rails.application.routes.draw do
	resources :links do
		collection do
			get 'search'
		end
 	end

  root 'links#index'
end
