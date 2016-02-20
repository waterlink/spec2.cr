module Spec2
  module Orders
    class Default
      include Order

      def order(list)
        list
      end
    end
  end
end
