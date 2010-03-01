# AwsWorkers::Ec2
#
# Author:: Christopher Meiklejohn (cmeik@me.com)
# Copyright:: Copyright (c) 2010 Christopher Meiklejohn
# License:: Distributes under the terms specified in the MIT-LICENSE file.
# 

module AwsWorkers

  # Ec2 worker.
  #
  # Defines a standard S3 worker object.
  # 
  class Ec2 < Worker

    # Accessors for access key and secret access key
    attr_accessor :ec2_access_key,
                  :ec2_secret_access_key

    # Creates the new Ec2 worker.
    #
    # Takes a RightAws::Ec2 object.
    # If object is nil, then we connect if 
    # access_key and secret_access_key options 
    # are present.
    #
    # TODO: Put in description about how to define
    # additional workers.  Workers should subclass
    # Ec2 (Worker).  Provide additional options,
    # and then call the launch_instance from superclass.
    #
    def initialize(ec2, options = {})

      # Call worker initalizer.
      super(options)

      # Send options back.
      options.each_pair do |key, value| 
        self.send("#{key}=", value)
      end

      # Log, but after logger is potentially 
      # overloaded :)
      @logger.debug("AwsWorkers::Ec2.new called")

      # S3 RightAws instance
      @ec2 = ec2

      # If s3 is nil, then we need to connect as 
      # long as the proper options have been passed 
      # through.
      if !@ec2 

        # Log it
        @logger.debug("AwsWorkers::Ec2.new nil Ec2 instance " +
                      "provided")

        if @ec2_access_key and @ec2_secret_access_key
          @logger.debug("AwsWorkers::Ec2.new access keys provided, " + 
                        "connecting")
          @ec2 = RightAws::Ec2.new(ec2_access_key, 
                                   ec2_secret_access_key)
        else
          @logger.debug("AwsWorkers::Ec2.new no access keys, " + 
                        "unable to establish connection")
        end
      end

    end

    # Launch Ec2 Instance
    #
    # Called by all Ec2 Workers
    def launch_instance
      @logger.debug("AwsWorkers::Ec2.launch_instance called")

      # TODO: Launch instance.
    end
  
  end

end
