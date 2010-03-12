# AwsWorkers::S3::BackupBucketTask
#
# Author:: Christopher Meiklejohn (cmeik@me.com)
# Copyright:: Copyright (c) 2010 Christopher Meiklejohn
# License:: Distributes under the terms specified in the MIT-LICENSE file.
#
require 'worker'

module AwsWorkers

  class S3 < Worker
    # Subclassed worker.

    # BackupBucketTask
    #
    # Defines a worker which will copy all new or 
    # changed assets from one S3 bucket to another S3 
    # bucket.
    # 
    class BackupBucketTask < S3

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
        @source_bucket =      @s3.bucket(@source_bucket_name)
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
        q = Queue.new

        # Iterate over the bucket.
        @source_bucket.keys.each do |source_key|

          # If the queue size is too big, sleep for a bit...
          # TODO: Abstract this out
          while q.size >= 50
            @logger.debug("AwsWorkers::S3::BackupBucketTask.execute " + 
                          "sleeping because queue is too full " + 
                          "#{q.size}")
            sleep 1
          end

          # Create the thread to run the backup in.  Add this thread to
          # the worker, pop inside the thread to maintain thread count.
          q << Thread.new do

            # Add it to the queue prior to execution...
            #q.push(asset_worker)
            #
            # This used to add the asset worker to the queue but then
            # there would be more than the allowed size running.  This
            # is because the time it would take for the queue to fill
            # up.  It seems that 18 threads could get launched before
            # the code caught the queue at 10, since it added to the
            # queue so late in the process.  Since we're treating this
            # as more of a count semaphore, and we don't need the entire
            # sync object in memory, just add a boolean 1 into the
            # queue.
            #q.push(1)

            # See above.

            @logger.debug("AwsWorkers::S3::BackupBucketTask.execute " + 
                          "executing sync in thread, adding new " + 
                          "worker to the queue")

            # Call asset synchronization worker.
            # 
            # Even though we have a connection, call with nil anyway, because we
            # are going to have to fork, which will require a new
            # connection.
            asset_worker =
              AwsWorkers::S3::SynchronizeAssetBetweenBucketsTask.new(
                nil,
                :s3_access_key => @s3_access_key,
                :s3_secret_access_key => @s3_secret_access_key,
                :source_key_name => source_key.to_s,
                :source_bucket_name => @source_bucket.to_s,
                :destination_bucket_name => @destination_bucket.to_s
            )


            # Remove me
            @logger.debug("AwsWorkers::S3::BackupBucketTask.execute " + 
                          "added to worker queue, current queue " + 
                          "size: #{q.size}")

            # Execute!
            asset_worker.execute

            # Remove it from the queue once execution is complete.
            q.pop
  
          end

        end

        # Wait for all of them to finish up!
        until q.empty?
          @logger.debug("AwsWorkers::S3::BackupBucketTask.execute " + 
                        "queue not empty, waiting: #{q.size}")
          sleep 1
        end

        @logger.debug("AwsWorkers::S3::BackupBucketTask.execute queue " +
                      "size after loop iteration: #{q.size}")

      end

      private

      # Setup defaults, if destination and location are not provided.
      def setup_defaults

        @logger.debug("AwsWorkers::S3::BackupBucketTask.setup_defaults called")

        @destination_bucket_name = "#{source_bucket_name}-backup" \
          if @destination_bucket_name.blank?
        @permissions = 'private' if @permissions.blank?

        # Blank location constraint is default, via Amazon API.
        #@location_constraint = "eu" \
        #  if @location_constraint.blank?

      end

    end

  end

end
