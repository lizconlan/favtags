ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  map.root :controller => "application"

  map.favorites '/favorites', :controller => 'favorites', :action => 'index'
  map.connect '/favorites', :controller => 'favorites', :action => 'tag'
  map.connect '/favorites/unfave', :controller => 'favorites', :action => 'delete'
  map.connect '/favorites/load', :controller => 'favorites', :action => 'load'
  
  map.connect '/favorites/accounts', :controller => 'favorites', :action => 'accounts'
  map.connect '/favorites/accounts/:account', :controller => 'favorites', :action => 'index'
  
  map.connect '/favorites/tag', :controller => 'favorites', :action => 'tag'
  map.connect '/favorites/tags', :controller => 'favorites', :action => 'tags'
  map.connect '/favorites/tags/:tag', :controller => 'favorites', :action => 'index'
  map.connect '/favorites/:id/detag/:tag', :controller => 'favorites', :action => 'remove_tag'
  map.connect '/favorites/new_tag', :controller => 'favorites', :action => 'new_tag'
  
  map.connect '/credits', :controller => 'application', :action => 'credits'
  
  map.connect '*bad_route', :controller => 'application', :action => 'render_not_found'
end
