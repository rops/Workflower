# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "workflow"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniele Rossetti"]
  s.date = "2013-04-09"
  s.description = "Workflows."
  s.email = "daniele.rossetti@me.com"
  s.extra_rdoc_files = ["README.rdoc", "lib/workflow.rb"]
  s.files = ["README.rdoc", "Rakefile", "lib/workflow.rb", "Manifest", "workflow.gemspec"]
  s.homepage = "http://github.com/rops"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Workflow", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "workflow"
  s.rubygems_version = "1.8.25"
  s.summary = "Workflows."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rails3_before_render>, [">= 0"])
    else
      s.add_dependency(%q<rails3_before_render>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails3_before_render>, [">= 0"])
  end
end
