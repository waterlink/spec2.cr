module Spec2
  module Output
    Factory.abstract
    
    abstract def print(style, string)

    def print(string)
      print(:normal, string)
    end

    def puts(string = "")
      puts(:normal, string)
    end

    def puts(style, string)
      print(style, "#{string}\n")
    end
  end
end
