# AwsWorkers::Ec2::BackupAllBucketsToSpecifiedLocationTask
#
# Author:: Christopher Meiklejohn (cmeik@me.com)
# Copyright:: Copyright (c) 2010 Christopher Meiklejohn
# License:: Distributes under the terms specified in the MIT-LICENSE file.
# 

module AwsWorkers

  class Ec2 < Worker
    # Subclassed worker.

    # Defines a worker which will launch a Ec2 
    # instance that will backup all S3 buckets.
    class BackupAllBucketsToSpecifiedLocationTask < Ec2

      # Define accessors and options needed for this 
      # particular worker.
      attr_accessor :s3_access_key,
                    :s3_secret_access_key,
                    :location_constraint,
                    :permissions,
                    :backup_suffix,
                    :max_thread_count

      # Call superclass initalizer, and 
      # then setup options which are local to 
      # this worker.
      def initialize(ec2, options = {})

        # Superclass call, takes care of loading options
        super(ec2, options)

        # Log it.
        @logger.debug("AwsWorkers::Ec2::BackupAllBucketsToSpecifiedLocationTask.new called")

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
        ['rubygems', 'cmeiklejohn-aws', 'aws_workers']
      end

      # Define method to execute on boot.
      def method_to_execute
        output = <<EOF
        worker = AwsWorkers::S3::BackupAllBucketsToSpecifiedLocationTask( 
          nil, 
          :s3_access_key =>         #{@access_key}, 
          :s3_secret_access_key =>  #{@secret_access_key},
          :location_constraint =>   #{@location_constraint},
          :permissions =>           #{@permissions},
          :backup_suffix =>         #{@backup_suffix}
          :max_thread_count =>      #{@max_thread_count}
        )
EOF
        output
      end
  
    end
  
  end

end
