require 'redmine'
require 'diff'
require 'rubygems'
require File.dirname(__FILE__) + '/lib/customer_documentator.rb'

Redmine::Plugin.register :redmine_customer_documentator do
  name 'Redmine Customer Documentator'
  author 'Abstraktor'
  description 'Mark wiki-pages as customer-documentation and allow explicit access to these pages.'
  version '0.0.1'
  
  project_module "wiki" do
    permission :show_customer_documentation, {:wiki => [:show, :index, :date_index]}, :require => :member
  	permission :mark_as_customer_documentation, {:wiki => :customer_documentation}
  end
end
