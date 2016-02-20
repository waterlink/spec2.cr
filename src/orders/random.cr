module Spec2
  module Orders
    class Random
      include Order

      def order(list)
        list.shuffle
      end
    end
  end
end
