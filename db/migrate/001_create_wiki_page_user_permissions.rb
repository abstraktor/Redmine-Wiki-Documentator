class CreateWikiPageUserPermissions < ActiveRecord::Migration
  def self.up
	  add_column :wiki_pages, :customer_documentation, :boolean, :default=>false, :null => false
  end

  def self.down
	  remove_column :wiki_pages, :customer_documentation
  end
end
