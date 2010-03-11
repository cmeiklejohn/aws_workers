# AwsWorkers::S3::BackupBucket
#
# Author:: Christopher Meiklejohn (cmeik@me.com)
# Copyright:: Copyright (c) 2010 Christopher Meiklejohn
# License:: Distributes under the terms specified in the MIT-LICENSE file.
#
# One required parameter, source_bucket_name, of S3 bucket to syncrhonize.
# 
# Two optional parameters:
#  destination_bucket_name: destination_bucket_name, defaults to 
#   source_bucket_name-backup
#  location_constraint: defaults to US-Standard
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
    class BackupBucket < S3

      # Accessors for information specific to backup bucket processing.
      attr_accessor :source_bucket_name,
                    :destination_bucket_name,
                    :permissions,
                    :location_constraint

      # Call superclass initalizer, and 
      # then setup options that are local 
      # to this worker.
      def initialize(s3, options = {}) 

        # Superclass call, handles S3 and Worker 
        # initialization
        super(s3, options)

        # Log it.
        @logger.debug("AwsWorkers::S3::BackupBucket.new called")

      end
  
      # Execute method
      def execute 

        # Perform logging.
        @logger.debug("AwsWorkers::S3::BackupBucket.execute called")

        # First, run the setup defaults routine for any local setup 
        # that needs to happen
        setup_defaults

        # Get handles to both buckets.
        @source_bucket =      @s3.bucket(@source_bucket_name)
        @destination_bucket = @s3.bucket(@destination_bucket_name,
                                         true,
                                         @permissions,
                                         :location => @location_constraint)

        @logger.debug("AwsWorkers::S3::BackupBucket.execute " + 
                      "source bucket accessed #{source_bucket_name}") if @source_bucket
        @logger.debug("AwsWorkers::S3::BackupBucket.execute " + 
                      "destination bucket accessed #{destination_bucket_name} " + 
                      "#{permissions} #{location_constraint} ") if @destination_bucket

        @source_bucket.keys.each do |source_key| 

          @logger.debug("AwsWorkers::S3::BackupBucket.execute " + 
                        "working on #{source_key}")

          # Look for destination key
          destination_key = RightAws::S3::Key.create(@destination_bucket, 
                                                     source_key.to_s)

          # If it exists...
          if destination_key.exists?

            @logger.debug("AwsWorkers::S3::BackupBucket.execute " + 
                          "#{destination_key} exists at destination")

            # Assess last modified time.
            source_key.head
            destination_key.head

            source_date = Time.parse(
              source_key.headers["last-modified"])
            destination_date = Time.parse(
              destination_key.headers["last-modified"])

            # Copy if neccessary.
            if source_date > destination_date 

              @logger.debug("AwsWorkers::S3::BackupBucket.execute " + 
                            "asset is newer at source, copying")

              source_key.copy(destination_key)

            else 

              @logger.debug("AwsWorkers::S3::BackupBucket.execute " + 
                            "asset is up to date")

            end

          else

            @logger.debug("AwsWorkers::S3::BackupBucket.execute " + 
                          "asset does not exist, copying")

            source_key.copy(destination_key)

          end

        end

      end

      private

      # Setup defaults, if destination and location are not provided.
      def setup_defaults

        @logger.debug("AwsWorkers::S3::BackupBucket.setup_defaults called")

        @destination_bucket_name = "#{source_bucket_name}-backup" \
          if @destination_bucket_name.blank?
        @permissions = 'public-read' if @permissions.blank?

        # Blank location constraint is default, via Amazon API.
        #@location_constraint = "eu" \
        #  if @location_constraint.blank?

      end

    end

  end

end
