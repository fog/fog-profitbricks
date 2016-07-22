require "fog/core"
require "fog/json"

require File.expand_path('profitbricks/version', __dir__)

module Fog
  module Compute
    autoload :ProfitBricks, File.expand_path('profitbricks/compute', __dir__)
  end

  module Models
    module ProfitBricks
      autoload :Base, File.expand_path('profitbricks/models/base', __dir__)
    end
  end

  module ProfitBricks
    extend Fog::Provider

    service(:compute, "Compute")
  end
end
