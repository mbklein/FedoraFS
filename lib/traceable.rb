module Traceable
  
  def self.included(mod)
    mod.module_eval do
      def output_trace_msg(msg)
        logdev = respond_to?(:logger) ? logger : $stderr
        if logdev.respond_to?(:debug)
          logdev.debug(msg)
        elsif logdev.respond_to?(:puts)
          logdev.puts(msg)
        else
          logdev << msg
        end
      end
      
      def self.trace(*method_names)
        method_names.each { |method_name|
          unless self.instance_methods.include?("__TRACE_#{method_name.to_s}__")
            self.class_eval do
              alias_method :"__TRACE_#{method_name.to_s}__", method_name
              define_method method_name do |*args, &block|
                output_trace_msg("TRACE : #{method_name}(#{args.collect { |a| a.inspect }.join(',')})")
                result = self.send(:"__TRACE_#{method_name.to_s}__", *args, &block)
                output_trace_msg("RESULT: #{result.inspect}")
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
