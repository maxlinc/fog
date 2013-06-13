require 'rspec'
require 'rspec/retry'
require 'open3'
require 'tempfile'
require 'fog'

RSpec.configure do |config|
  config.verbose_retry = true # show retry status in spec process
  config.default_retry_count = 3
end

examples = Dir['*/*.rb']

# I'd prefer to use example => arguments, but example => input will work until examples accept command line args.
pid = Process.pid
server_name = "test_server_#{pid}"
commands = {
  "compute_v2/create_server.rb" => "#{server_name}",
  # Confirm
  "compute_v2/resize_server.rb" => "0\n4\nC",
  # Revert
  # "compute_v2/resize_server.rb" => "0\n4\nR",
  "compute_v2/server_attachments.rb" => "0\nmy_volume_#{pid}",
  "block_storage/create_volume.rb" => "1\n100\nanother_volume_#{pid}",
  "block_storage/create_snapshot.rb" => "0\n0\nmy_snapshot_#{pid}",
  "block_storage/delete_volume.rb" => "0",
  "compute_v2/create_image.rb" => "0\nmy_image_#{pid}",
  "compute_v2/delete_image.rb" => "0",
  "compute_v2/detach_volume.rb" => "0\n0\nn",
  "compute_v2/server_metadata.rb" => "",
  "storage/create_cdn_directory.rb" => "cdn_#{pid}",
  "storage/create_private_directory.rb" => "private_#{pid}",
  "storage/delete_directory.rb" => "0",
  "storage/upload_file.rb" => "lorem_#{pid}",
  "storage/upload_large_files.rb" => "0\n../../../../changelog.txt",
  "storage/download_file.rb" => "0\n0",
  "storage/delete_file.rb" => "0\n0",
  "storage/storage_metadata.rb" => "",
  "compute_v2/delete_server.rb" => "0",
}

describe "Examples" do
  it "should have commands for every example" do
    commands.keys.sort.should eq examples.sort
  end

  it "should start clean" do
    # Because the input relies on numbering, these tests will be unreliable if things already exist
    connection_opts = {
      :provider             => 'Rackspace',
      :rackspace_username   => Fog.credentials[:rackspace_username],
      :rackspace_api_key    => Fog.credentials[:rackspace_api_key],
      :rackspace_region => :ord #Use Chicago Region
    }
    compute = Fog::Compute.new(connection_opts.merge({:version => :v2}))
    storage = Fog::Storage.new(connection_opts)
    block_storage =  Fog::Rackspace::BlockStorage.new(connection_opts.reject{|name,value| name == :provider})
    if ENV['DESTROY'] == 'true'
      storage.directories.each do |directory|
        directory.files.each do | file |
          file.destroy
        end
        directory.destroy
      end
      compute.servers.each do |server|
        server.destroy
      end
      block_storage.snapshots.each do |snapshot|
        snapshot.destroy
      end
      block_storage.volumes.each do |volume|
        volume.destroy
      end
    end
    compute.servers.size.should == 0
    storage.directories.size.should == 0
    block_storage.snapshots.size.should == 0
    block_storage.volumes.size.should == 0
  end

  # iterate on commands, not examples, because test order matters
  commands.each do |example, args|
    it "in #{example} should pass" do
      puts "About to run #{example}"
      input = Tempfile.new('input')
      input << args
      input.flush
      input.close
      system "bundle exec ruby #{example} < #{input.path}"
      $?.should == 0
    end
  end
end
