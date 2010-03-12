# AwsWorkers::S3::SynchronizeAssetBetweenBucketsTask
#
# Author:: Christopher Meiklejohn (cmeik@me.com)
# Copyright:: Copyright (c) 2010 Christopher Meiklejohn
# License:: Distributes under the terms specified in the MIT-LICENSE file.
#
require 'worker'

module AwsWorkers

  class S3 < Worker

    class SynchronizeAssetBetweenBucketsTask < S3

      # TODO: setup_defaults need to raise exceptions if these are not
      # present
      attr_accessor :source_key_name,
                    :source_bucket_name,
                    :destination_bucket_name

      def initialize(s3, options = {}) 

        super(s3, options)

        # Log it.
        @logger.debug("AwsWorkers::S3::SynchronizeAssetBetweenBucketsTask.new called")

      end

      # Execute method
      def execute 

        # Perform logging.
        @logger.debug("AwsWorkers::S3::SynchronizeAssetBetweenBucketsTask.execute called")

        # First, run the setup defaults routine for any local setup 
        # that needs to happen
        setup_defaults

        # Get handles to both buckets.
        @source_bucket =      @s3.bucket(@source_bucket_name)
        @destination_bucket = @s3.bucket(@destination_bucket_name)

        @logger.debug("AwsWorkers::S3::SynchronizeAssetBetweenBucketsTask.execute " + 
                      "source bucket accessed #{source_bucket_name}") if @source_bucket
        @logger.debug("AwsWorkers::S3::SynchronizeAssetBetweenBucketsTask.execute " + 
                      "destination bucket accessed #{destination_bucket_name}")
                      

        # Get source key
        source_key = RightAws::S3::Key.create(@source_bucket, 
                                              @source_key_name)

        @logger.debug("AwsWorkers::S3::SynchronizeAssetBetweenBucketsTask.execute " + 
                      "working on #{@source_key_name} source_key: " + 
                      "#{source_key.to_s} source_key.exists?: " + 
                      "#{source_key.exists?}")

        # Look for destination key
        destination_key = RightAws::S3::Key.create(@destination_bucket, 
                                                   source_key.to_s)

        # If it exists...
        if destination_key.exists? and source_key.exists?

          @logger.debug("AwsWorkers::S3::SynchronizeAssetBetweenBucketsTask.execute " + 
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

            @logger.debug("AwsWorkers::S3::SynchronizeAssetBetweenBucketsTask.execute " + 
                          "asset is newer at source, copying")

            source_key.copy(destination_key)

          else 

            @logger.debug("AwsWorkers::S3::SynchronizeAssetBetweenBucketsTask.execute " + 
                          "asset is up to date")

          end

        else

          @logger.debug("AwsWorkers::S3::SynchronizeAssetBetweenBucketsTask.execute " + 
                        "asset does not exist, copying")

          source_key.copy(destination_key)

        end

      end

      private

      # Setup defaults, if destination and location are not provided.
      def setup_defaults

        @logger.debug("AwsWorkers::S3::SynchronizeAssetBetweenBucketsTask.setup_defaults called")

      end

    end

  end

end
