# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{aws_workers}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christopher Meiklejohn"]
  s.cert_chain = ["/home/cmeiklejohn/.gemcert/gem-public_cert.pem"]
  s.date = %q{2010-03-12}
  s.description = %q{Amazon Web Services workers for common AWS tasks.}
  s.email = %q{cmeik@me.com}
  s.extra_rdoc_files = ["README.rdoc", "lib/aws_workers.rb", "lib/aws_workers/ec2.rb", "lib/aws_workers/ec2/backup_s3_buckets_task.rb", "lib/aws_workers/s3.rb", "lib/aws_workers/s3/backup_all_buckets_task.rb", "lib/aws_workers/s3/backup_bucket_task.rb", "lib/aws_workers/s3/synchronize_asset_between_buckets_task.rb", "lib/aws_workers/worker.rb"]
  s.files = ["Manifest", "README.rdoc", "Rakefile", "lib/aws_workers.rb", "lib/aws_workers/ec2.rb", "lib/aws_workers/ec2/backup_s3_buckets_task.rb", "lib/aws_workers/s3.rb", "lib/aws_workers/s3/backup_all_buckets_task.rb", "lib/aws_workers/s3/backup_bucket_task.rb", "lib/aws_workers/s3/synchronize_asset_between_buckets_task.rb", "lib/aws_workers/worker.rb", "aws_workers.gemspec"]
  s.homepage = %q{http://github.com/cmeiklejohn/aws_workers}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Aws_workers", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{aws_workers}
  s.rubygems_version = %q{1.3.5}
  s.signing_key = %q{/home/cmeiklejohn/.gemcert/gem-private_key.pem}
  s.summary = %q{Amazon Web Services workers for common AWS tasks.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
