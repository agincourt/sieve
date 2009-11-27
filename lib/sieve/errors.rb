module Sieve
  module Errors
    class NoColumnError < StandardError
    end
    
    class DuplicateDefaultError < StandardError
    end
    
    class NotOptionError < StandardError
    end
  end
end