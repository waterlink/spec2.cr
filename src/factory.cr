module Spec2
  module Factory
    macro abstract
      module Factory
        abstract def build : {{@type}}
      end
    end
  end
end
