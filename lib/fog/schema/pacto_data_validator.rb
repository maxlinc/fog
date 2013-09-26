module Fog
  module Schema
    class PactoDataValidator
      
      def initialize
        @message = nil
      end

      def validate(data, schema, options = {})
        result = schema.validate(data, :body_only => true)
        unless result.empty?
          @message = result.join "\n"
        end
        result.empty?
      end

      def message
        @message
      end
    end
  end
end