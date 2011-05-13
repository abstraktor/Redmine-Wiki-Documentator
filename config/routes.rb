ActionController::Routing::Routes.draw do |map|
  map.resources :projects do |project|
   project.connect 'wiki/:id/customer_documentation', :controller=>:wiki, :action=>:customer_documentation
  end
end

