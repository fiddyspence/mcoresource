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

    svcs.send(@resource[:action].to_sym, :force=> true, :process_results => false)
  end
  def filterhandle
    	


  end

end
