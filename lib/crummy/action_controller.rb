module Crummy
  module ControllerMethods
    module ClassMethods
      # Add a crumb to the crumbs array.
      #
      #   add_crumb("Home", "/")
      #   add_crumb(lambda { |instance| instance.business_name }, "/")
      #   add_crumb("Business") { |instance| instance.business_path }
      #
      # Works like a before_filter so +:only+ and +except+ both work.
      def add_crumb(name, *args)
        options = args.extract_options!
        url = args.first
        raise ArgumentError, "Need more arguments" unless name or options[:record] or block_given?
        raise ArgumentError, "Cannot pass url and use block" if url && block_given?
        before_action(options) do |instance|
          url = yield instance if block_given?
          url = instance.send url if url.is_a? Symbol
          
          if url.present?
            if url.kind_of? Array
              url.map! do |name|
                name.is_a?(Symbol) ? instance.instance_variable_get("@#{name}") : name
              end
            end
            if not url.kind_of? String
              url = instance.send :url_for, url
            end
          end

          # Get the return value of the name if its a proc.
          name = name.call(instance) if name.is_a?(Proc)

          _record = instance.instance_variable_get("@#{name}") unless name.kind_of?(String)
          if _record and _record.respond_to? :to_param
            instance.add_crumb(_record.to_s, url || instance.url_for(_record), options)
          else 
            instance.add_crumb(name, url, options)
          end
        
          # FIXME: url = instance.url_for(name) if name.respond_to?("to_param") && url.nil?
          # FIXME: Add ||= for the name, url above
        end
      end

      def clear_crumbs
        before_filter do |instance|
          instance.clear_crumbs
        end
      end
    end

    module InstanceMethods
      # Add a crumb to the crumbs array.
      #
      #   add_crumb("Home", "/")
      #   add_crumb("Business") { |instance| instance.business_path }
      #
      def add_crumb(name, url=nil, options={})
        crumbs.push [name, url, options]
      end

      def clear_crumbs
        crumbs.clear
      end

      # Lists the crumbs as an array
      def crumbs
        get_or_set_ivar "@_crumbs", []
      end

      def get_or_set_ivar(var, value) # :nodoc:
        instance_variable_set var, instance_variable_get(var) || value
      end
      private :get_or_set_ivar
    end

    def self.included(receiver) # :nodoc:
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
