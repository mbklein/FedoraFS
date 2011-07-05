module Traceable
  
  def self.included(mod)
    mod.module_eval do
      unless self.instance_methods.include?('logger')
        require 'logger'
        def logger
          @__trace_logger__ ||= Logger.new($stderr)
        end
      end
      
      def self.trace(*method_names)
        method_names.each { |method_name|
          unless self.instance_methods.include?("__TRACE_#{method_name.to_s}__")
            self.class_eval do
              alias_method :"__TRACE_#{method_name.to_s}__", method_name
              define_method method_name do |*args, &block|
                logger.debug("TRACE : #{method_name}(#{args.collect { |a| a.inspect }.join(',')})")
                result = self.send(:"__TRACE_#{method_name.to_s}__", *args, &block)
                logger.debug("RESULT: #{result.inspect}")
                result
              end
            end
          end
        }
      end
      
      def self.untrace(*method_names)
        method_names.each { |method_name|
          if self.instance_methods.include?("__TRACE_#{method_name.to_s}__")
            self.class_eval do
              alias_method method_name, :"__TRACE_#{method_name.to_s}__"
              undef_method :"__TRACE_#{method_name.to_s}__"
            end
          end
        }
      end
    end
  end
    
end
