# AwsWorkers
#
# Author:: Christopher Meiklejohn (cmeik@me.com)
# Copyright:: Copyright (c) 2010 Christopher Meiklejohn
# License:: Distributes under the terms specified in the MIT-LICENSE file.
# 

$:.unshift(File.dirname(__FILE__))

require 'aws_workers/s3'
require 'aws_workers/ec2'
require 'aws_workers/worker'

require 'aws_workers/s3/backup_bucket'
require 'aws_workers/s3/backup_all_buckets'
require 'aws_workers/ec2/backup_s3_buckets'

module AwsWorkers #:nodoc:
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 0
    TINY =  1

    STRING = [MAJOR, MINOR, TINY].join('.')
  end
end
