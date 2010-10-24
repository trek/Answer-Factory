# encoding: UTF-8
class Workstation
  # Sets up a new machine with the given machine_name. If a class_name is
  # provided, sets up a built-in machine; otherwise sets up a generic machine.
  # The config block is evaluated in the scope of the new machine.
  # 
  #   Factory.setup do
  #     workstation :w do
  #       machine :my_builtin_machine, :GenerateRandomAnswer do
  #         ...
  #       end
  #       
  #       machine :my_generic_machine do
  #         ...
  #       end
  #     end
  #   end
  # 
  # Use this method inside a Factory.workstation block.
  # 
  def machine (machine_name, class_name = :Machine, &config)
    machine_name = machine_name.to_sym
    machine = Object.const_get(class_name).new
    machine.instance_variable_set(:@location, "#{@name}:#{machine_name}")
    machine.instance_variable_set(:@process, proc { machine.process_answers })
    machine.instance_eval(&config) if config

    @machines[machine_name] = machine
    @schedule << machine_name
    machine
  end
  
  # Schedules machines in the given order. Default is one schedule item per
  # machine, in order of creation.
  # 
  #   Factory.setup
  #     workstation :w do
  #       machine :a do ... end
  #       machine :b do ... end
  #       machine :c do ... end
  #     end
  #     
  #     # (current schedule is :a, :b, :c)
  #     
  #     schedule :a, :b, :c, :c, :b
  #   end
  # 
  # Use this method inside a Factory.workstation block.
  # 
  def schedule (*machine_names)
    @schedule = machine_names.collect {|name| name.to_sym }
  end
  
  # Internal use only. Defined by Workstation subclasses.
  def setup
  end
  
  # Internal use only.
  def initialize (name)
    @name = name
    @machines = {}
    @schedule = []
  end
end
