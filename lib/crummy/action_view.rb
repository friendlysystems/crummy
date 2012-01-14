module Crummy
  module ViewMethods
    # List the crumbs as an array
    def crumbs
      begin
        crumb = YAML.load(session[:history])
      rescue
        crumb = []
      end
      crumb
    end

    # Add a crumb to the +crumbs+ array
    # Proc tady tadle metoda vubec je, pouziva se?
    def add_crumb(name, url=nil)
      c = crumbs
      truncated_name = truncate name, :length => 25
      crumb = [trucated_name, url]
      c.delete crumb
      c << crumb
      c.shift if c.size > 5
      session[:history] = c.to_yaml
    end

    # Render the list of crumbs using renderer
    #
    def render_crumbs(options = {})
      options[:format] = :html if options[:format] == nil
      if options[:seperator] == nil
        options[:seperator] = " &raquo; " if options[:format] == :html
        options[:seperator] = "crumb" if options[:format] == :xml
      end
      options[:links] = true if options[:links] == nil
      case options[:format]
      when :html
        crumb_string = crumbs.collect do |crumb|
          crumb_to_html crumb, options[:links]
        end * options[:seperator]
        crumb_string = crumb_string.html_safe if crumb_string.respond_to?(:html_safe)
        crumb_string
      when :xml
        crumbs.collect do |crumb|
          crumb_to_xml crumb, options[:links], options[:seperator]
        end * ''
      else
        raise "Unknown breadcrumb output format"
      end
    end

    def crumb_to_html(crumb, links)
      name, url = crumb
      url && links ? link_to(name, url) : name
    end

    def crumb_to_xml(crumb, links, seperator)
      name, url = crumb
      url && links ? "<#{seperator} href=\"#{url}\">#{name}</#{seperator}>" : "<#{seperator}>#{name}</#{seperator}>"
    end
  end
end
