require 'fog/core/collection'
require 'fog/compute/models/bluebox/image'

module Fog
  module Compute
    class Bluebox

      class Images < Fog::Collection

        model Fog::Compute::Bluebox::Image

        def all
          data = connection.get_templates.body
          load(data)
        end

        def get(template_id)
          response = connection.get_template(template_id)
          new(response.body)
        rescue Fog::Compute::Bluebox::NotFound
          nil
        end

      end

    end
  end
end
