module AwsKeys
  class KeyNotFoundException < Exception; end

  class Key
    attr_reader :id, :secret, :token

    def initialize (id, secret, token = nil)
      @id = id
      @secret = secret
      @token = token
    end

  end

  PATHS = [".ec2"]
  PATHS.push(File.expand_path("~/.ec2")) if ENV["HOME"]
  PATHS.push("/etc/ec2")

  def self.role_key (rolename = nil)
    require 'open-uri'
    require 'json'

    return unless File.exist? "/etc/ec2_version"
    unless rolename
      rolename = open("http://169.254.169.254/2012-01-12/meta-data/iam/security-credentials").read
      return unless (rolename && rolename.length > 0)
    end

    data = open("http://169.254.169.254/2012-01-12/meta-data/iam/security-credentials/#{rolename}").read rescue nil
    return unless (data && data.length > 0)

    d = JSON.parse(data)
    return unless d

    return Key.new(d["AccessKeyId"], d["SecretAccessKey"], d["Token"])
  rescue
    nil
  end

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

  def self.keys (type, match_all = true)
    path = match_all ? key_path(type) : find_key_path(type)
    return unless path
    data = File.read(path)
    # Explicitly match with regex, to make sure our data is right
    re = /AWSAccessKeyId=([A-Z0-9]+)\nAWSSecretKey=([^\n]+)\n?$/
    return Key.new($1, $2) if data =~ re
    return
  end

  # Guaranteed to return a key, or exits the program
  def self.keys! (type)
    k = keys(type)

    unless k
      STDERR.puts "Could not find key of type: #{type}"
      STDERR.puts "Please make sure one of these files exists:"
      PATHS.each { |p| STDERR.puts "* #{File.expand_path p}/#{type}.creds" }
      exit 233
    end

    k
  end
end
