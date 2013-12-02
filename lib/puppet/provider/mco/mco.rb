require 'mcollective'
Puppet::Type.type(:mco).provide(:mco) do

  def options
    options = MCollective::Util.default_options
    options[:agent] = @resource[:agent]
    options[:config] = @resource[:configfile]
    options[:verbose] = false
    options[:process_results] = false
    options[:mcollective_limit_targets] = false
    options[:disctimeout] = 2
    options[:timeout] = 2
    options[:collective] = 'mcollective'
    options[:force] = 'true'

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
    Puppet.debug("We received the filter: #{@resource[:filter].inspect}")
    unless @resource[:filter].empty?
      svcs.identity_filter @resource[:filter]['identity']
      svcs.class_filter @resource[:filter]['class']
    end
    extra_params = options_to_sym(@resource[:parameters])
    Puppet.debug(extra_params.inspect)
    if extra_params
      svcs.send @resource[:action].to_sym, extra_params
    else
      svcs.send @resource[:action].to_sym
    end
  end

  def options_to_sym(param)
    options = {} 
    if param
      param.each do |thing,value|
        options[thing.to_sym] = value
      end
    end
    if @resource[:wait] == 'true' or !!@resource[:wait] == @resource[:wait]
      Puppet.debug "This was true: #{@resource[:wait]}"
      options[:force] = false
      options[:process_results] = true
    else
      Puppet.debug @resource[:wait]
      options[:force] = true
      options[:process_results] = false
    end
    options
  end
end
