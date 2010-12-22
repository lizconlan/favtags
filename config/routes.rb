ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  map.root :controller => "application"

  map.favorites '/favorites', :controller => 'favorites', :action => 'index'
  map.connect '/favorites.:format', :controller => 'favorites', :action => 'index'
  map.connect '/favorites/unfave', :controller => 'favorites', :action => 'delete'
  map.connect '/favorites/load', :controller => 'favorites', :action => 'load'
  
  map.connect '/favorites/accounts', :controller => 'favorites', :action => 'accounts'
  map.connect '/favorites/accounts/:account', :controller => 'favorites', :action => 'index'
  
  map.connect '/favorites/tag', :controller => 'favorites', :action => 'tag'
  map.connect '/favorites/:id/detag/:tag', :controller => 'favorites', :action => 'remove_tag'
  map.connect '/favorites/new_tag', :controller => 'favorites', :action => 'new_tag'
  map.connect '/favorites/:id/retweet', :controller => 'favorites', :action => 'retweet'
    
  map.connect '/favorites/tags', :controller => 'tags', :action => 'index'
  map.merge '/favorites/merge_tags', :controller => 'tags', :action => 'merge'
  map.connect '/favorites/tags/:tag', :controller => 'favorites', :action => 'index'
  map.connect '/favorites/tags/:tag.:format', :controller => 'favorites', :action => 'index'
  map.connect '/favorites/tags/:tag/delete', :controller => 'tags', :action => 'delete'
  map.connect '/favorites/tags/:tag/rename', :controller => 'tags', :action => 'rename'
  
  map.connect '/credits', :controller => 'application', :action => 'credits'
  
  map.account '/account', :controller => 'users', :action => 'index'
  map.close_account '/close_account', :controller => 'users', :action => 'leave'
  map.exit '/exit', :controller => 'application', :action => 'exit'
  
  map.connect '*bad_route', :controller => 'application', :action => 'render_not_found'
end
