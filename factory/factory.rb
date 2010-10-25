# encoding: UTF-8
class Factory
  Infinity = 1.0 / 0
  
  # Sets up workstations and their scheduled order. The config block is
  # evaluated in the scope of the Factory object.
  # 
  #   Factory.setup do
  #     ...
  #   end
  # 
  # Use this method in {my_factory_directory}/config/setup.rb.
  # 
  def Factory.setup (&config)
    Factory.instance_eval(&config)
  end
  
  # Sets up a new workstation with the given workstation_name. If a class_name
  # is provided, sets up a built-in workstation; otherwise sets up a generic
  # workstation. The config block is evaluated in the scope of the new
  # workstation.
  # 
  #   Factory.setup do
  #     workstation :my_builtin_workstation, :RandomGenerator do
  #       ...
  #     end
  #     
  #     workstation :my_generic_workstation do
  #       ...
  #     end
  #   end
  # 
  # Use this method inside a Factory.setup block.
  # 
  def Factory.workstation (workstation_name, class_name = :Workstation, &config)
    workstation_name = workstation_name.to_sym
    workstation = Factory.const_get(class_name).new(workstation_name)
    workstation.setup
    workstation.instance_eval(&config) if config
    
    (@workstations ||= {})[workstation_name] = workstation
    (@schedule ||= []) << workstation_name
  end
  
  # Schedules workstations in the given order. Default is one schedule item
  # per workstation, in order of creation.
  # 
  #   Factory.setup
  #     workstation :a do ... end
  #     workstation :b do ... end
  #     workstation :c do ... end
  #     
  #     # (current schedule is :a, :b, :c)
  #     
  #     schedule :a, :b, :c, :c, :b
  #   end
  # 
  # Use this method inside a Factory.setup block.
  # 
  def Factory.schedule (*workstation_names)
    @schedule = workstation_names.collect {|name| name.to_sym }
  end
  
  # Instructs Factory to stop running at the end of any schedule loop in
  # which n answers are found in the Factory. Default behavior is to run
  # without stopping until interrupted by the user.
  # 
  #   Factory.setup
  #     ...
  #     
  #     stop_at 100_000
  #   end
  # 
  # Use this method inside a Factory.setup block.
  # 
  def Factory.stop_at (n)
    @answer_limit = n
  end
  
  # Internal use only.
  def Factory.start (comment = "")
    return unless @workstations && @schedule
    
    Factory.log_comment(comment)
    
    machine_loop = []
    
    @schedule.each do |workstation_name|
      @workstations[workstation_name].instance_eval do
        @schedule.each do |machine_name|
          machine_loop << @machines[machine_name]
        end
      end
    end
    
    until @answer_limit && Factory.answer_count > @answer_limit
      machine_loop.each {|m| m.run }
      Factory.cycle!
    end
  end
  
  # Defined by adapter module:
  #   Factory.answer_count
  #   Factory.cycle
  #   
  #   Internal use only:
  #     Factory.set_database (options)
  #     Factory.migrate
  #     Factory.zap
  #     Factory.cycle!
  #     Factory.count_answers_at_machine (location)
  #     Factory.load_answers_at_machine (location, load_scores = false)
  #     Factory.save_answers (answers)
  #     Factory.save_scores (scores)
end
