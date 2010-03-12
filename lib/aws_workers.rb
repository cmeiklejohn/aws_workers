# AwsWorkers
#
# Author:: Christopher Meiklejohn (cmeik@me.com)
# Copyright:: Copyright (c) 2010 Christopher Meiklejohn
# License:: Distributes under the terms specified in the MIT-LICENSE file.
# 
$:.unshift(File.dirname(__FILE__))

# Main libraries
require 'aws_workers/s3'
require 'aws_workers/ec2'
require 'aws_workers/worker'

# S3 tasks
require 'aws_workers/s3/backup_bucket_task'
require 'aws_workers/s3/backup_all_buckets_task'
require 'aws_workers/s3/synchronize_asset_between_buckets_task'

# EC2 tasks
require 'aws_workers/ec2/backup_s3_buckets_task'

module AwsWorkers #:nodoc:
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 0
    TINY =  1

    STRING = [MAJOR, MINOR, TINY].join('.')
  end
end
