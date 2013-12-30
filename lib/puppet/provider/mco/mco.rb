require 'mcollective'
Puppet::Type.type(:mco).provide(:mco) do

  def options
    options = MCollective::Util.default_options
    options[:agent] = @resource[:agent]
    options[:config] = @resource[:configfile]
    options[:verbose] = false
    options[:mcollective_limit_targets] = false
    options[:disctimeout] = 2
    options[:timeout] = 2
    options[:collective] = 'mcollective'

    if @resource[:optionhash]
      @resource[:optionhash].each do |thing,value|
        options[thing.to_sym] = value
      end
    end
    options

  end

  def mcollective(agent,action,filter)
    config = options
    Puppet.debug("#{config.inspect}")
    identityfilter,factfilter = []

    svcs = MCollective::RPC::Client.new(@resource[:agent], :options => config)

    unless @resource[:filter].empty?
      svcs.identity_filter @resource[:filter]['identity']
      svcs.class_filter @resource[:filter]['class']
      svcs.compound_filter @resource[:filter]['compound']
    end
    
    extra_params = options_to_sym(@resource[:parameters])

    action_result = svcs.send @resource[:action].to_sym, extra_params
    if action_result.is_a?(String)
      0
    else
#      action_result.results
      return_data = []
      action_result.each do |result|
        return_data << result[:sender]
      end
      Puppet.debug "return_data: #{return_data.inspect}"
      return_data
    end
  end

  def options_to_sym(param)
    local_options = {} 
    if param
      param.each do |thing,value|
        local_options[thing.to_sym] = value
      end
    end
    if @resource[:wait] == 'true' or !!@resource[:wait] == true
      local_options[:process_results] = true
    else
      local_options[:process_results] = false
    end
    Puppet.debug("#{local_options.inspect}")
    local_options

  end
end
