# AwsWorkers::Ec2::BackupS3BucketsTask
#
# Author:: Christopher Meiklejohn (cmeik@me.com)
# Copyright:: Copyright (c) 2010 Christopher Meiklejohn
# License:: Distributes under the terms specified in the MIT-LICENSE file.
# 

module AwsWorkers

  class Ec2 < Worker
    # Subclassed worker.

    # BackupS3BucketsTask
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
    class BackupS3BucketsTask < Ec2

      # Define accessors and options needed for this 
      # particular worker.
      attr_accessor :s3_access_key,
                    :s3_secret_access_key,
                    :location_constraint,
                    :permissions,
                    :backup_suffix

      # Call superclass initalizer, and 
      # then setup options which are local to 
      # this worker.
      def initialize(ec2, options = {})

        # Superclass call, takes care of loading options
        super(ec2, options)

        # Log it.
        @logger.debug("AwsWorkers::Ec2::BackupS3BucketsTask.new called")

      end

      private

      # Define required software, debian package file list.
      #
      # Only used if the AMI requires installation of software 
      # before code can be executed.
      def required_packages
        ['ruby', 'rubygems', 'libopenssl-ruby']
      end

      # Define list of required gems.
      #
      # Only used if the AMI requires installation of software 
      # before code can be executed.
      def required_gems
        ['rubygems', 'right_aws', 'aws_workers']
      end

      # Define method to execute on boot.
      def method_to_execute
        output <<EOF
        worker = AwsWorkers::S3::BackupAllBucketsTask( 
          nil, 
          :s3_access_key =>         #{@access_key}, 
          :s3_secret_access_key =>  #{@secret_access_key},
          :location_constraint =>   #{@location_constraint},
          :permissions =>           #{@permissions},
          :backup_suffix =>         #{@backup_suffix}
        )
EOF
        output
      end
  
    end
  
  end

end
