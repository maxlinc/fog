module Fog
  module Rackspace
    class LoadBalancers
      class Real
        def get_load_balancer(load_balancer_id)
          request(
            :expects => 200,
            :path => "loadbalancers/#{load_balancer_id}.json",
            :method => 'GET'
          )
         end
      end

      class Mock
        def get_load_balancer(load_balancer_id)
          response = Excon::Response.new

          load_balancer_id ||= 0
          response = Excon::Response.new
          request_signature = WebMock::RequestSignature.new :get, "https://ord.loadbalancers.api.rackspacecloud.com/v1.0/0/loadbalancers/#{load_balancer_id}.json"
          request_signature.headers = {'Accept' => 'application/json'}
          contract = Pacto.contract_for(request_signature).first
          stub_response = contract.response.instantiate
          response.body = stub_response.body
          response.status = stub_response.status
          require 'pry'; binding.pry
          response
         end
      end

    end
  end
end
