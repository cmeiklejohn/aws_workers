# AwsWorkers::S3
#
# Author:: Christopher Meiklejohn (cmeik@me.com)
# Copyright:: Copyright (c) 2010 Christopher Meiklejohn
# License:: Distributes under the terms specified in the MIT-LICENSE file.
#
require 'worker'

module AwsWorkers

  # S3 worker.
  #
  # Defines a standard S3 worker object.
  # 
  class S3 < Worker

    # Accessors for access key and secret access key
    attr_accessor :s3_access_key,
                  :s3_secret_access_key
  
    # Create a new S3 worker.  
    # 
    # Takes a RightAws::S3 object.
    # If object is nil, then we connect if 
    # access_key and secret_access_key options 
    # are present.
    def initialize(s3, options = {})

      # Call worker initalizer.
      super(options)

      # Send options back.
      options.each_pair do |key, value| 
        self.send("#{key}=", value)
      end

      # Log, but after logger is potentially 
      # overloaded :)
      @logger.debug("AwsWorkers::S3.new called")

      # S3 RightAws instance
      @s3 = s3

      # If s3 is nil, then we need to connect as 
      # long as the proper options have been passed 
      # through.
      if !@s3 

        # Log it
        @logger.debug("AwsWorkers::S3.new nil S3 instance " +
                      "provided")

        if @s3_access_key and @s3_secret_access_key
          @logger.debug("AwsWorkers::S3.new access keys provided, " + 
                        "connecting")
          @s3 = RightAws::S3.new(s3_access_key, 
                                 s3_secret_access_key,
                                 :multi_thread => true)
        else
          @logger.debug("AwsWorkers::S3.new no access keys, " + 
                        "unable to establish connection")
        end
      end

    end

  end

end
