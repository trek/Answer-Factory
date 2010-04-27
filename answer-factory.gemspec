# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{answer-factory}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bill Tozier", "Trek Glowacki", "Jesse Sielaff"]
  s.date = %q{2010-04-27}
  s.default_executable = %q{answer-factory}
  s.description = %q{The pragmaticgp gem provides a simple framework for building, running and managing genetic programming experiments which automatically discover algorithms and equations to solve user-defined problems.}
  s.email = %q{bill@vagueinnovation.com}
  s.executables = ["answer-factory"]
  s.extra_rdoc_files = [
    "LICENSE.txt"
  ]
  s.files = [
    ".gitignore",
     "LICENSE.txt",
     "Rakefile",
     "Thorfile",
     "VERSION",
     "_spikes/old_vs_new_dominated_by?.rb",
     "answer-factory.gemspec",
     "bin/answer-factory",
     "config/database.yml",
     "lib/answer-factory.rb",
     "lib/answers/answer.rb",
     "lib/answers/batch.rb",
     "lib/factories/factory.rb",
     "lib/factories/workstation.rb",
     "lib/operators/basic_operators.rb",
     "lib/operators/evaluators.rb",
     "lib/operators/samplers_and_selectors.rb",
     "pkg/nudgegp-0.0.1.gem",
     "readme.md",
     "spec/answer_spec.rb",
     "spec/batch_spec.rb",
     "spec/config_spec.rb",
     "spec/factories/factory_spec.rb",
     "spec/factories/workstation_spec.rb",
     "spec/operators/any_one_sampler_spec.rb",
     "spec/operators/dominated_quantile_spec.rb",
     "spec/operators/duplicate_genomes_spec.rb",
     "spec/operators/evaluators/program_point_evaluator_spec.rb",
     "spec/operators/evaluators/test_case_evaluator_spec.rb",
     "spec/operators/infrastructure_spec.rb",
     "spec/operators/most_dominated_subset_spec.rb",
     "spec/operators/nondominated_subset_spec.rb",
     "spec/operators/pointCrossover_spec.rb",
     "spec/operators/pointDeletion_spec.rb",
     "spec/operators/pointMutation_spec.rb",
     "spec/operators/random_guess_spec.rb",
     "spec/operators/resample_and_clone_spec.rb",
     "spec/operators/resample_values_spec.rb",
     "spec/operators/uniformBackboneCrossover_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/Vaguery/PragGP}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.1")
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Genetic Programming in the Nudge language}
  s.test_files = [
    "spec/answer_spec.rb",
     "spec/batch_spec.rb",
     "spec/config_spec.rb",
     "spec/factories/factory_spec.rb",
     "spec/factories/workstation_spec.rb",
     "spec/operators/any_one_sampler_spec.rb",
     "spec/operators/dominated_quantile_spec.rb",
     "spec/operators/duplicate_genomes_spec.rb",
     "spec/operators/evaluators/program_point_evaluator_spec.rb",
     "spec/operators/evaluators/test_case_evaluator_spec.rb",
     "spec/operators/infrastructure_spec.rb",
     "spec/operators/most_dominated_subset_spec.rb",
     "spec/operators/nondominated_subset_spec.rb",
     "spec/operators/pointCrossover_spec.rb",
     "spec/operators/pointDeletion_spec.rb",
     "spec/operators/pointMutation_spec.rb",
     "spec/operators/random_guess_spec.rb",
     "spec/operators/resample_and_clone_spec.rb",
     "spec/operators/resample_values_spec.rb",
     "spec/operators/uniformBackboneCrossover_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nudge>, [">= 0.2"])
      s.add_runtime_dependency(%q<thor>, [">= 0.13"])
      s.add_runtime_dependency(%q<couchrest>, [">= 0.33"])
      s.add_runtime_dependency(%q<fakeweb>, [">= 0.33"])
      s.add_runtime_dependency(%q<sinatra>, [">= 0.9.4"])
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.5"])
    else
      s.add_dependency(%q<nudge>, [">= 0.2"])
      s.add_dependency(%q<thor>, [">= 0.13"])
      s.add_dependency(%q<couchrest>, [">= 0.33"])
      s.add_dependency(%q<fakeweb>, [">= 0.33"])
      s.add_dependency(%q<sinatra>, [">= 0.9.4"])
      s.add_dependency(%q<activesupport>, [">= 2.3.5"])
    end
  else
    s.add_dependency(%q<nudge>, [">= 0.2"])
    s.add_dependency(%q<thor>, [">= 0.13"])
    s.add_dependency(%q<couchrest>, [">= 0.33"])
    s.add_dependency(%q<fakeweb>, [">= 0.33"])
    s.add_dependency(%q<sinatra>, [">= 0.9.4"])
    s.add_dependency(%q<activesupport>, [">= 2.3.5"])
  end
end

