Puppet::Type.newtype(:mco) do

  @doc = <<-EOS
    This type provides a core resource to trigger MCollective
  EOS


  def self.newcheck(name, options = {}, &block)
    @checks ||= {}

    check = newparam(name, options, &block)
    @checks[name] = check
  end

  def self.checks
    @checks.keys
  end

  newproperty(:returns) do
    desc "What we got back from the mcollective run - probably some kind of object, but as yet this isn't properly parsed" 
    defaultto "0"

    munge do | value|
      value.to_s
    end

    def retrieve
      if @resource.check_all_attributes
        return :notrun
      else
        return self.should
      end
    end

    def sync
      @status = provider.mcollective(self.resource[:agent],self.resource[:action],self.resource[:filter])
      self.send(@resource[:loglevel],@status)
    end
  end

  newparam(:name, :namevar => true) do
    desc 'The name of the job for the catalog'
  end

  newparam(:wait) do
    desc "whether to block on the mcollective run, or just abandon the responses to the RPC call"

    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:agent) do
    desc "The mcollective agent we want to call"
  end

  newparam(:action) do
    desc 'The action on the agent'
  end

  newparam(:filter, :array_matching => :all) do
    desc 'What filtering to apply - either identity => [] class => [], or later discovery filtering on other things'
    ourkeys = ['identity','class','iwonderifthiswillwork']
    validate do |whatdidwegetgiven|
      whatdidwegetgiven.each do |k,v|
        raise ArgumentError, "Filter allowable hash keys are 'identity', 'class', 'iwonderifthiswillwork'" unless ourkeys.member?(k)
      end
    end
    defaultto []
  end

  newparam(:parameters, :array_matching => :all) do
    desc 'Other parameters to pass to the agent (e.g. package => openssl to the status action on the package agent'
  end

  newparam(:optionhash, :array_matching => :all) do
    desc 'Other mcollective options to override defaults'
  end
  newparam(:configfile) do
    desc 'File on disk to load as the client configuration'
    defaultto '/etc/puppetlabs/puppet/client/cfg'

    validate do |config|
      raise ArgumentError, "#{config} is not an absolute path" unless File.absolute_path(config) == config
    end
  end

  newcheck(:refreshonly) do
    desc 'Trigger every time or not (false means yes, true means no) - works the same as refreshonly on an exec {}'
    newvalues(:true, :false)
    defaultto :true
    def check(value)
      # We have to invert the values.
      if value == :true
        false
      else
        true
      end
    end
  end

  def refresh
    self.property(:returns).sync
  end

  autorequire(:file) do
    self[:configfile] if self[:configfile]
  end

  def check_all_attributes(refreshing = false)
    self.class.checks.each { |check|
      next if refreshing and check == :refreshonly
      if @parameters.include?(check)
        val = @parameters[check].value
        val = [val] unless val.is_a? Array
        val.each do |value|
          return false unless @parameters[check].check(value)
        end
      end
    }

    true
  end
end
