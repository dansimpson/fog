unless Fog.mocking?

  module Fog
    module AWS
      class S3

        # Get an object from S3
        #
        # ==== Parameters
        # * bucket_name<~String> - Name of bucket to read from
        # * object_name<~String> - Name of object to read
        # * options<~Hash>:
        #   * 'If-Match'<~String> - Returns object only if its etag matches this value, otherwise returns 412 (Precondition Failed).
        #   * 'If-Modified-Since'<~Time> - Returns object only if it has been modified since this time, otherwise returns 304 (Not Modified).
        #   * 'If-None-Match'<~String> - Returns object only if its etag differs from this value, otherwise returns 304 (Not Modified)
        #   * 'If-Unmodified-Since'<~Time> - Returns object only if it has not been modified since this time, otherwise returns 412 (Precodition Failed).
        #   * 'Range'<~String> - Range of object to download
        # ==== Returns
        # * response<~Fog::AWS::Response>:
        #   * body<~String> - Contents of object
        #   * headers<~Hash>:
        #     * 'Content-Length'<~String> - Size of object contents
        #     * 'Content-Type'<~String> - MIME type of object
        #     * 'ETag'<~String> - Etag of object
        #     * 'Last-Modified'<~String> - Last modified timestamp for object
        def get_object(bucket_name, object_name, options = {})
          headers = {}
          headers['If-Modified-Since'] = options['If-Modified-Since'].utc.strftime("%a, %d %b %Y %H:%M:%S +0000") if options['If-Modified-Since']
          headers['If-Unmodified-Since'] = options['If-Unmodified-Since'].utc.strftime("%a, %d %b %Y %H:%M:%S +0000") if options['If-Modified-Since']
          headers.merge!(options)
          request({
            :expects  => 200,
            :headers  => headers,
            :host     => "#{bucket_name}.#{@host}",
            :method   => 'GET',
            :path     => object_name
          })
        end

      end
    end
  end

else

  module Fog
    module AWS
      class S3

        def get_object(bucket_name, object_name, options = {})
          response = Fog::Response.new
          if (bucket = Fog::AWS::S3.data[:buckets][bucket_name]) && (object = bucket[:objects][object_name])
            if options['If-Match'] && options['If-Match'] != object['ETag']
              response.status = 412
            elsif options['If-Modified-Since'] && options['If-Modified-Since'] > Time.parse(object['LastModified'])
              response.status = 304
            elsif options['If-None-Match'] && options['If-None-Match'] == object['ETag']
              response.status = 304
            elsif options['If-Unmodified-Since'] && options['If-Unmodified-Since'] < Time.parse(object['LastModified'])
              response.status = 412
            else
              response.status = 200
              response.headers = {
                'Content-Length'  => object['Size'],
                'ETag'            => object['ETag'],
                'Last-Modified'   => object['LastModified']
              }
              response.body = object[:body]
            end
          else
            response.status = 404
            raise(Fog::Errors.status_error(200, 404, response))
          end
          response
        end

      end
    end
  end

end