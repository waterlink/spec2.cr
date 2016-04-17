module Spec2
  module Orders
    class Default
      include Order
      extend Order::Factory

      def self.build
        new
      end

      def order(list)
        list
      end
    end
  end
end
