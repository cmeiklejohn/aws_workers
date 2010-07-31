# AwsWorkers::S3::BackupBucketTask
#
# Author:: Christopher Meiklejohn (cmeik@me.com)
# Copyright:: Copyright (c) 2010 Christopher Meiklejohn
# License:: Distributes under the terms specified in the MIT-LICENSE file.
#
require 'worker'

module AwsWorkers

  class S3 < Worker

    # Defines a worker which will copy all new or 
    # changed assets from one S3 bucket to another S3 
    # bucket.
    class BackupBucketTask < S3

      # Accessors for information specific to backup bucket processing.
      attr_accessor :source_bucket_name,
                    :destination_bucket_name,
                    :permissions,
                    :location_constraint,
                    :max_thread_count

      # Call superclass initalizer, and 
      # then setup options that are local 
      # to this worker.
      def initialize(s3, options = {}) 

        # Superclass call, handles S3 and Worker 
        # initialization
        super(s3, options)

        # Log it.
        @logger.debug("AwsWorkers::S3::BackupBucketTask.new called")

      end

      # Execute method
      def execute 

        # Perform logging.
        @logger.debug("AwsWorkers::S3::BackupBucketTask.execute called")

        # First, run the setup defaults routine for any local setup 
        # that needs to happen
        setup_defaults

        # Get handles to both buckets.
        @source_bucket = @s3.bucket(@source_bucket_name)

        if !@source_bucket 
          raise "Source bucket #{@source_bucket_name} does not exist."
        end

        @destination_bucket = @s3.bucket(@destination_bucket_name,
                                         true,
                                         @permissions,
                                         :location => @location_constraint)

        @logger.debug("AwsWorkers::S3::BackupBucketTask.execute " + 
                      "source bucket accessed #{source_bucket_name}") if @source_bucket
        @logger.debug("AwsWorkers::S3::BackupBucketTask.execute " + 
                      "destination bucket accessed #{destination_bucket_name} " + 
                      "#{permissions} #{location_constraint} ") if @destination_bucket

        # Set up the queue.
        key_queue = Queue.new
        thread_queue = Queue.new

        # Iterate over keys, and put them in the queue
        @source_bucket.keys.each do |source_key|
          key_queue << source_key
        end

        # Print the queue size
        @logger.debug("AwsWorkers::S3::BackupBucketTask.execute " + 
                      "Queue size: #{key_queue.size}")

        # Launch the proper number of threads.
        1.upto(@max_thread_count) do
          @logger.debug("AwsWorkers::S3::BackupBucketTask.execute " + 
                        "Launching thread...")

          # Create the thread
          thread_queue << Thread.new do 

            # Thread will continuously pop keys off the queue and work
            # them.
            until key_queue.empty?
              source_key = key_queue.pop

              @logger.debug("AwsWorkers::S3::BackupBucketTask.execute " + 
                            "Working on key: #{source_key}")

              # Create the asset worker
              asset_worker =
                AwsWorkers::S3::SynchronizeAssetBetweenBucketsTask.new(
                  nil,
                  :s3_access_key => @s3_access_key,
                  :s3_secret_access_key => @s3_secret_access_key,
                  :source_key_name => source_key.to_s,
                  :source_bucket_name => @source_bucket.to_s,
                  :destination_bucket_name => @destination_bucket.to_s
              )

              # Begin the synchronization
              asset_worker.execute
            end
          end
        end

        # Wait for all of the threads to finish
        until thread_queue.empty?
          # Pop thread off queue
          thread = thread_queue.pop

          @logger.debug("AwsWorkers::S3::BackupBucketTask.execute " + 
                        "Waiting for thread: #{thread.inspect}")

          # Join thread to main thread
          thread.join
        end

      end

      private

      # Setup defaults, if destination and location are not provided.
      def setup_defaults

        @logger.debug("AwsWorkers::S3::BackupBucketTask.setup_defaults called")

        @permissions = 'private' if @permissions.blank?
        @max_thread_count = 1 if @max_thread_count.blank?

        raise "Source bucket missing." if @source_bucket_name.blank?
        raise "Destination bucket missing." if @destination_bucket_name.blank?
      end

    end

  end

end
