module Spec2
  module Orders
    class Random
      include Order
      extend Order::Factory

      def self.build
        new
      end

      def order(list)
        list.shuffle
      end
    end
  end
end
