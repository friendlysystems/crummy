module Crummy
  module ControllerMethods
    module ClassMethods
      # Add a crumb to the crumbs array.
      #
      #   add_crumb("Home", "/")
      #   add_crumb("Business") { |instance| instance.business_path }
      #
      # Works like a before_filter so +:only+ and +except+ both work.
      def add_crumb(name, *args)
        options = args.extract_options!
        url = args.first
        raise ArgumentError, "Need more arguments" unless name or options[:record] or block_given?
        raise ArgumentError, "Cannot pass url and use block" if url && block_given?
        before_filter(options) do |instance|
          url = yield instance if block_given?
          url = instance.send url if url.is_a? Symbol
          record = instance.instance_variable_get("@#{name}") unless url or block_given?
          if record and record.respond_to? :to_param
            name, url = record.to_s, instance.url_for(record)
          end

          # FIXME: url = instance.url_for(name) if name.respond_to?("to_param") && url.nil?
          # FIXME: Add ||= for the name, url above
          instance.add_crumb(name, url)
        end
      end
    end

    module InstanceMethods
      include ActionView::Helpers::TextHelper
      # Add a crumb to the crumbs array.
      #
      #   add_crumb("Home", "/")
      #   add_crumb("Business") { |instance| instance.business_path }
      #
      def add_crumb(name, url=nil)
       c = crumbs
       truncated_name = truncate name, :length => 25
       crumb = [truncated_name, url]
       c.delete crumb
       c << crumb
       c.shift if c.size > 5
       session[:history] = c.to_yaml
      end

      # Lists the crumbs as an array
      def crumbs
        begin
          crumbs = YAML.load(session[:history])
        rescue
          puts "haluz"
          crumbs = []
        end
        crumbs
      end
    end

    def self.included(receiver) # :nodoc:
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
