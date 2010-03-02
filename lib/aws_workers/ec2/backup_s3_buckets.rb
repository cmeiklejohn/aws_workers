# AwsWorkers::Ec2::BackupS3Buckets
#
# Author:: Christopher Meiklejohn (cmeik@me.com)
# Copyright:: Copyright (c) 2010 Christopher Meiklejohn
# License:: Distributes under the terms specified in the MIT-LICENSE file.
# 

module AwsWorkers

  class Ec2 < Worker
    # Subclassed worker.

    # BackupS3Buckets
    #
    # Defines a worker which will launch a Ec2 
    # instance that will backup all S3 buckets.
    #
    # Subclasses of Ec2 Workers must implement
    # a initalizer, att_accessors for information
    # required to pass through to the instance, and
    # user_data routine which is passed into the 
    # Ec2 instance as user-data (which is executed
    # on boot as root).
    #
    class BackupS3Buckets < Ec2

      # Define accessors and options needed for this 
      # particular worker.
      attr_accessor :s3_access_key,
                    :s3_secret_access_key

      # Call superclass initalizer, and 
      # then setup options which are local to 
      # this worker.
      def initialize(ec2, options = {})

        # Superclass call, takes care of loading options
        # hash through polymorphism.
        super(ec2, options)

        # Log it.
        @logger.debug("AwsWorkers::Ec2::BackupS3Buckets.new called")

      end

      private

      # Define required software, debian package file list.
      #
      # Only used if the AMI requires installation of software 
      # before code can be executed.
      def required_packages
        ['ruby', 'rubygems']
      end

      # Define list of required gems.
      #
      # Only used if the AMI requires installation of software 
      # before code can be executed.
      def required_gems
        ['right_aws', 'aws_tools']
      end

      # Define method to execute on boot.
      def method_to_execute
        "puts 'hi'"
      end
  
    end
  
  end

end
