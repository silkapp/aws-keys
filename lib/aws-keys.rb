module AwsKeys
  class KeyNotFoundException < Exception; end

  PATHS = [".ec2"]
  PATHS.push(File.expand_path("~/.ec2")) if ENV["HOME"]
  PATHS.push("/etc/ec2")

  def self.find_key_path (type)
    PATHS.each do |path|
      key_path = File.join(path, "#{type}.creds")
      return key_path if File.exists? key_path
    end
    return
  end

  def self.key_path (type)
    find_key_path(type) || find_key_path("all")
  end

  def self.keys (type)
    path = key_path(type)
    return unless path
    data = File.read(path)
    # Explicitly match with regex, to make sure our data is right
    re = /AWSAccessKeyId=([A-Z0-9]+)\nAWSSecretKey=([^\n]+)\n?$/
    return { :id => $1, :secret => $2 } if data =~ re
    return
  end

  # Raises an exception if the keys can't be found
  def self.keys! (type)
    k = keys(type)
    raise KeyNotFoundException.new("Could not find key of type: #{type}") unless k
    k
  end
end