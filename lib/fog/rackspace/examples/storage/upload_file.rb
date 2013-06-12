#!/usr/bin/env ruby

# This example demonstrates creating a file on the CDN network with the Rackpace Open Cloud

require 'rubygems' #required for Ruby 1.8.x
require 'fog'
require 'optparse'

def run
  parse_options
  file = create_file if @options[:create]
  delete_file file if @options[:delete]
  if file && !@options[:delete]
    puts "You should not be able to view this file via CDN at #{file.public_url}"
    puts "To delete the container and associated file please execute the delete_directory.rb script\n\n" 
  end
end

def create_file  
  # prompt for directory name
  directory_name = @options[:directory_name] || get_user_input("\nEnter name of directory to create")

  # create directory with CDN service
  directory = @service.directories.create :key => directory_name, :public => true

  # upload file
  upload_file = File.join(File.dirname(__FILE__), "lorem.txt")
  file = directory.files.create :key => 'sample.txt', :body => File.open(upload_file, "r")
  
  puts "\nFile #{file.key} was successfully created"
  file
end

def delete_file(file)
  if file.nil?
    # retrieve directories with files
    directories = @service.directories.select {|s| s.count > 0}
      
    # prompt for directory
    directory = select_directory(directories)

    # list of files for directory
    files = directory.files

    # prompt for file to delete
    file = select_file(files)
  end

  # delete file
  file.destroy

  puts "\nFile #{file.key} was successfully deleted"
end

def parse_options
  @options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: upload_file.rb [options]"
    @options[:create] = true
    @options[:delete] = false

    opts.on("-d", "--dir DIRECTORY",
        "Name of directory to create") do |dir|
      @options[:directory_name] = dir
    end
    opts.on("-c", "--[no-]create", "Create a file") do |create|
      @options[:create] = create
    end
    opts.on("-x", "--[no-]delete", "Delete a file") do |delete|
      @options[:delete] = delete
    end
  end.parse!
end

def get_user_input(prompt)
  print "#{prompt}: "
  gets.chomp
end

# Use username defined in ~/.fog file, if absent prompt for username. 
# For more details on ~/.fog refer to http://fog.io/about/getting_started.html
def rackspace_username
  Fog.credentials[:rackspace_username] || get_user_input("Enter Rackspace Username")
end

# Use api key defined in ~/.fog file, if absent prompt for api key
# For more details on ~/.fog refer to http://fog.io/about/getting_started.html
def rackspace_api_key
  Fog.credentials[:rackspace_api_key] || get_user_input("Enter Rackspace API key")
end

def select_directory(directories)
  abort "\nThere are not any directories with files to delete in the Chicago region. Try running create_file.rb\n\n" if directories.empty?
  
  puts "\nSelect Directory:\n\n"
  directories.each_with_index do |dir, i|
    puts "\t #{i}. #{dir.key} [#{dir.count} objects]"
  end

  delete_str = get_user_input "\nEnter Directory Number"
  directories[delete_str.to_i]
end

def select_file(files)
  puts "\nSelect File:\n\n"
  files.each_with_index do |file, i|
    puts "\t #{i}. #{file.key}"
  end

  delete_str = get_user_input "\nEnter File Number"
  files[delete_str.to_i]
end

# create Cloud Files service
@service = Fog::Storage.new({
  :provider             => 'Rackspace',
  :rackspace_username   => rackspace_username,
  :rackspace_api_key    => rackspace_api_key,
  :rackspace_region => :ord #Use Chicago Region
  })

run