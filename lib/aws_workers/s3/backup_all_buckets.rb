# AwsWorkers::S3::BackupAllBuckets
#
# Author:: Christopher Meiklejohn (cmeik@me.com)
# Copyright:: Copyright (c) 2010 Christopher Meiklejohn
# License:: Distributes under the terms specified in the MIT-LICENSE file.
#
require 'worker'

module AwsWorkers

  class S3 < Worker
    # Subclassed worker.

    # BackupBucket
    #
    # Defines a worker which will copy all new or 
    # changed assets from one S3 bucket to another S3 
    # bucket.
    # 
    class BackupAllBuckets < S3

      # Attributes specific to this call.
      attr_accessor :location_constraint,
                    :permissions,
                    :backup_suffix

      # Call superclass initalizer, and 
      # then setup options that are local 
      # to this worker.
      def initialize(s3, options = {}) 

        # S3 and Worker initalizer
        super(s3, options)

        # Log it.
        @logger.debug("AwsWorkers::S3::BackupAllBuckets.new called")

      end
  
      # Execute method
      def execute 
        
        @logger.debug("AwsWorkers::S3::BackupAllBuckets.execute called") 

        # Setup default values
        setup_defaults

        # Run through the sync
        #
        # Synchronize all buckets that are in US Standard.
        # So, this code assumes that source buckets are standard, and non-source are foreign.
        @s3.buckets.each do |source_bucket|

          @logger.debug("AwsWorkers::S3::BackupAllBuckets.exceute " + 
                        "working on #{source_bucket}")

          if source_bucket.location.empty?

            destination_bucket_name = "#{source_bucket}#{backup_suffix}"

            @logger.debug("AwsWorkers::S3::BackupAllBuckets.exceute " + 
                          "attempting to sync #{source_bucket} to #{destination_bucket_name}")

            sync_worker = AwsWorkers::S3::BackupBucket.new(
              @s3,
              :location_constraint => @location_constraint,
              :permissions => @permissions,
              :source_bucket_name => source_bucket.to_s,
              :destination_bucket_name => destination_bucket_name
            )

            sync_worker.execute

          end

        end

      end

      private

      # Setup defaults
      def setup_defaults

        @logger.debug("AwsWorkers::S3::BackupAllBuckets.setup_defaults called")
    
        # Location constraint defaults to blank
        @location_constraint = "" if @location_constraint.blank?
        @permissions = 'public-read' if @permissions.blank?
        @backup_suffix = '-backup' if @backup_suffix.blank?

      end

    end

  end

end
