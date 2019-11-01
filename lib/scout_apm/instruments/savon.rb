module ScoutApm
  module Instruments
    class Savon
      attr_reader :context

      def initialize(context)
        @context = context
        @installed = false
      end

      def logger
        context.logger
      end

      def installed?
        @installed
      end

      def install
        if defined?(::Savon) && defined?(::Savon::Client)
          @installed = true

          logger.info "Instrumenting Savon"

          ::Savon::Client.class_eval do
            include ScoutApm::Tracer

            def call_with_scout_instruments(*args, &block)
              operation_name = args.first rescue "Unknown"

              self.class.instrument("Savon", operation_name) do
                call_without_scout_instruments(*args, &block)
              end
            end

            alias_method :call_without_scout_instruments, :call
            alias_method :call, :call_with_scout_instruments
          end
        end
      end
    end
  end
end
