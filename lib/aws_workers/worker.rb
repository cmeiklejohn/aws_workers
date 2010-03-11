# AwsWorkers::Worker
#
# Author:: Christopher Meiklejohn (cmeik@me.com)
# Copyright:: Copyright (c) 2010 Christopher Meiklejohn
# License:: Distributes under the terms specified in the MIT-LICENSE file.
# 
module AwsWorkers

  # Worker class.
  #
  # Defines things common to a worker.
  #
  # Access keys are defined in each worker, as 
  # you may want to launch a EC2 to perform
  # S3 tasks with independent keys.
  class Worker

    # Accessor for logger.
    attr_accessor :logger

    # Called by all workers.
    def initialize(options = {})

      # If there's no logger, let's get it setup.
      @logger = Logger.new(STDOUT) if !@logger

    end

  end

end
