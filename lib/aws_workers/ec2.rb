# AwsWorkers::Ec2
#
# Author:: Christopher Meiklejohn (cmeik@me.com)
# Copyright:: Copyright (c) 2010 Christopher Meiklejohn
# License:: Distributes under the terms specified in the MIT-LICENSE file.
# 

module AwsWorkers

  # Ec2 worker
  #
  # Defines a standard S3 worker object.
  # 
  class Ec2 < Worker

    # Accessors for access key and secret access key
    attr_accessor :ec2_access_key,
                  :ec2_secret_access_key

    # Accessors for required Ec2 parameters
    attr_accessor :ami,
                  :min_count,
                  :max_count,
                  :security_group,
                  :key_name,
                  :addressing_type,
                  :instance_type,
                  :kernel_id,
                  :ramdisk_id,
                  :availability_zone,
                  :monitoring_enabled,
                  :subnet_id,
                  :disable_api_termination,
                  :instance_initiated_shutdown_behavior,
                  :block_device_mappings

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

      # Setup defaults for things that might not have them.
      setup_defaults

      # Run the instance via right_aws
      @logger.debug("AwsWorkers::Ec2.launch_instance launching")

      @ec2.run_instances(@ami, 
                         @min_count,
                         @max_count,
                         @security_group, 
                         @key_name,
                         user_data,
                         @addressing_type,
                         @instance_type,
                         @kernel_id,
                         @ramdisk_id,
                         @availability_zone,
                         @monitoring_enabled,
                         @subnet_id,
                         @disable_api_termination,
                         @instance_initiated_shutdown_behavior,
                         @block_device_mappings)
    end

    private

    # Setup some defaults, for things that may or may not be specified.
    def setup_defaults
      @logger.debug("AwsWorkers::Ec2.setup_defaults called")

      @min_count = 1                  if @min_count.blank?
      @max_count = 1                  if @max_count.blank?
      @security_group = 'default'     if @security_group.blank?
      @key_name = 'default'           if @key_name.blank?
      @addressing_type = 'public'     if @addressing_type.blank?
      @instance_type = 'm1.small'     if @instance_type.blank?
      # @kernel_id = nil              if @kernel_id.blank?
      # @ramdisk_id = nil             if @ramdisk_id.blank?
      # @availability_zone = nil      if @availability_zone.blank?
      # @monitoring_enabled = nil     if @monitoring_enabled.blank?
      # @subnet_id = nil              if @subnet_id.blank?
      # @disable_api_termination = nil 
      #                 if @disable_api_termination.blank?
      # @instance_initiated_shutdown_behavior = nil 
      #                 if @instance_initiated_shutdown_behavior.blank?
      # @block_device_mappings = nil  if @block_device_mappings.blank?
    end
  
  end

end

