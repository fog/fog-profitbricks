module Fog
  module Helpers
    module ProfitBricks
      module DataHelper
        def flatten(response_json)
          ['properties', 'metadata', 'entities'].each {|k| response_json.merge!(response_json.delete(k)) if response_json.has_key?(k)}
          response_json
        end
      end
    end
  end
end
