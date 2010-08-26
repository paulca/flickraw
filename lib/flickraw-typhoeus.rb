require 'flickraw'
require 'typhoeus'

module FlickRaw
  class Flickr
    def async
      @async ||= Typhoeus::Hydra.new
    end

    alias :old_call :call
    def call(req, args={}, &block)
      @token = nil if req == "flickr.auth.getFrob"
      request = Typhoeus::Request.new("#{FLICKR_HOST}#{REST_PATH}",
        :method => :post,
        :headers => {'User-Agent' => "Flickraw/#{VERSION}"},
        :params => build_args(args, req))
      request.on_complete do |http_response|
        res = process_response(req,http_response)
        yield(res) if block_given?
        res
      end
      if block_given?
        async.queue request
      else
        async.queue request
        async.run
        request.handled_response
      end
    end
  end
end