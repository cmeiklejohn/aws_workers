# AwsWorkers::S3::BackupAllBucketsToSpecifiedLocationTask
#
# Author:: Christopher Meiklejohn (cmeik@me.com)
# Copyright:: Copyright (c) 2010 Christopher Meiklejohn
# License:: Distributes under the terms specified in the MIT-LICENSE file.
#
require 'worker'

module AwsWorkers

  class S3 < Worker

    # Backup all buckets from one zone to another, and add a prefix to
    # the backup buckets since bucket name must be unique.
    #
    # Since there is no naming persistance from one run of this script
    # to another, this could potentially backup a backup 
    # if run from zone to zone.  
    #
    # Blank constraint means US-Standard
    class BackupAllBucketsToSpecifiedLocationTask < S3

      # Attributes specific to this call.
      attr_accessor :permissions,
                    :backup_suffix,
                    :max_thread_count,
                    :source_location_constraint,
                    :destination_location_constraint

      # Call superclass initalizer, and 
      # then setup options that are local 
      # to this worker.
      def initialize(s3, options = {}) 

        # S3 and Worker initalizer
        super(s3, options)

        # Log it.
        @logger.debug("AwsWorkers::S3::BackupAllBucketsToSpecifiedLocationTask.new called")

      end
  
      # Execute method
      def execute 
        
        @logger.debug("AwsWorkers::S3::BackupAllBucketsToSpecifiedLocationTask.execute called") 

        # Setup default values
        setup_defaults

        # Run through the sync
        #
        # Synchronize all buckets that are in US Standard.
        # So, this code assumes that source buckets are standard, and non-source are foreign.
        @s3.buckets.each do |source_bucket|

          @logger.debug("AwsWorkers::S3::BackupAllBucketsToSpecifiedLocationTask.exceute " + 
                        "working on #{source_bucket}")

          @logger.debug("source_bucket.location = #{source_bucket.location}")
          @logger.debug("@source_location_constraint = #{@source_location_constraint}")

          if source_bucket.location == @source_location_constraint ||
             (source_bucket.location.empty? && @source_location_constraint.blank?)

            destination_bucket_name = "#{source_bucket}#{backup_suffix}"

            @logger.debug("AwsWorkers::S3::BackupAllBucketsToSpecifiedLocationTask.exceute " + 
                          "attempting to sync #{source_bucket} to #{destination_bucket_name}")

           sync_worker = AwsWorkers::S3::BackupBucketTask.new(
              nil,
              :s3_access_key => @s3_access_key,
              :s3_secret_access_key => @s3_secret_access_key,
              :location_constraint => @destination_location_constraint,
              :permissions => @permissions,
              :source_bucket_name => source_bucket.to_s,
              :destination_bucket_name => destination_bucket_name,
              :max_thread_count => @max_thread_count
            )

            sync_worker.execute

          end

        end

      end

      private

      # Setup defaults
      def setup_defaults

        @logger.debug("AwsWorkers::S3::BackupAllBucketsToSpecifiedLocationTask.setup_defaults " +
                      "called")
 
        @permissions =        'public-read' if @permissions.blank?
        @backup_suffix =      '-backup'     if @backup_suffix.blank?
        @max_thread_count =   1             if @max_thread_count.blank?

        raise "Source and destination location can not be the same." \
          if @source_location_constraint == @destination_location_constraint

      end

    end

  end

end
