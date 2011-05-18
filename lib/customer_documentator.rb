module CustomerDocumentator
  module MixinSearchController
    def self.included base
      base.class_eval do
			  alias_method :_index, :index unless method_defined? :_index

        def index
          _index
          
          if @results != nil
            @results.delete_if do |result|
              result.class == WikiPage and
              not User.current.can_view? result
            end
          end
        end
        
      end      
    end
  end
  module MixinWikiPage
    def self.included base
      
    end
  end
  
  module MixinUser
    def self.included base
      base.class_eval do
            
        def can_view? page          
				  admin or
					allowed_to? :view_wiki_pages, page.wiki.project or 
					(allowed_to? :show_customer_documentation, page.wiki.project and page.customer_documentation )
        end
      end
    end
  end
  
  module MixinWikiController
    def self.included base
      base.class_eval do
        alias_method :_load_pages_grouped_by_date_without_content, :load_pages_grouped_by_date_without_content unless method_defined? :load_pages_grouped_by_date_without_content
				alias_method :_show,  :show  unless method_defined? :_show
        
        def load_pages_grouped_by_date_without_content 
          _load_pages_grouped_by_date_without_content
          cleanup_page_hierarchy @pages
					cleanup_page_hierarchy @pages_by_date
					cleanup_page_hierarchy @pages_by_parent_id
        end

				def show
				  if not User.current.can_view? @wiki.find_or_new_page(params[:id])
						flash.now[:error] = "Zur Seite #{params[:id]} hast du keinen Zugang!" unless params[:id].blank? or params[:id] == @wiki.find_page("")
					  params[:id] = "Nutzerdokumentation"
						_show
					else
            _show
				  end
        end

        before_filter :find_existing_page, :only => [:customer_documentation]
				def customer_documentation
				  @page.update_attribute :customer_documentation, params[:customer_documentation]
 				  redirect_to :action => 'show', :project_id => @project, :id => @page.title
				end

        private
				def cleanup_page_hierarchy(pages)
				  # this doesnt work
					#FIXME
				  pages.delete_if do |k,el|
					  if not el.nil? and el.include? Enumerable
              cleanup_page_hierarchy(el)
						end
						logger.info "\nho #{el.title}, #{User.current.can_view? el}" if el.class ==  WikiPage
						el.kind_of?(WikiPage) and not User.current.can_view? el
					end
				end

      end
    end  
  end
end

require 'dispatcher'
  Dispatcher.to_prepare do 
    begin
      require_dependency 'application'
    rescue LoadError
      require_dependency 'application_controller'
    end

  WikiController.send :include, CustomerDocumentator::MixinWikiController
  SearchController.send :include, CustomerDocumentator::MixinSearchController
  User.send :include, CustomerDocumentator::MixinUser
  end
