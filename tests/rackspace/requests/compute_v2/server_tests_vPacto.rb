require 'Pacto'
Shindo.tests('Fog::Compute::RackspaceV2 | server_tests', ['rackspace']) do
  service   = Fog::Compute.new(:provider => 'Rackspace', :version => 'V2')
  image_id  = Fog.credentials[:rackspace_image_id]
  image_id ||= Fog.mocking? ? service.images.first.id : service.images.find {|image| image.name =~ /Ubuntu/}.id # use the first Ubuntu image
  flavor_id = Fog.credentials[:rackspace_flavor_id] || service.flavors.first.id

  link_format = {
    'href' => String,
    'rel' => String
  }

  server_format = {
    'id' => String,
    'name' => String,
    'hostId' => Fog::Nullable::String,
    'created' => Fog::Nullable::String,
    'updated' => Fog::Nullable::String,
    'status' => Fog::Nullable::String,
    'progress' => Fog::Nullable::Integer,
    'user_id' => Fog::Nullable::String,
    'tenant_id' => Fog::Nullable::String,
    'links' => [link_format],
    'metadata' => Fog::Nullable::Hash
  }

  list_servers_format = {
    'servers' => [server_format]
  }

  get_server_format = Pacto.load_schema(:get_server)

  create_server_format = Pacto.load_schema(:create_server)
  

  rescue_server_format = {
    'adminPass' => Fog::Nullable::String
  }

  tests('success') do

    server_id = nil
    server_name = "fog#{Time.now.to_i.to_s}"
    image_id = image_id
    flavor_id = flavor_id

    tests("#create_server(#{server_name}, #{image_id}, #{flavor_id}, 1, 1)").formats(create_server_format) do
      body = service.create_server(server_name, image_id, flavor_id, 1, 1).body
      server_id = body['server']['id']
      body
    end
    wait_for_server_state(service, server_id, 'ACTIVE', 'ERROR')
   
    tests('#get_server').formats(get_server_format, false) do
      service.get_server(server_id).body
    end

  end 
end
