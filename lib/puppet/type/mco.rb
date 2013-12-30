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

  newproperty(:returns, :array_matching => :all) do
    defaultto 0

    validate do |value|
      unless value.is_a?(Array)

      end
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

      if self.should[0].to_i == self.should[0]
        if @status.size != @resource[:returns][0].to_i
          self.fail("We choked on size: #{@status} - expected #{self.should}")
        end
      else
        @resource[:returns].each do |node|
          Puppet.debug node
          self.fail("We choked: #{@status}") unless @status.include?(node) 
        end
      end
      self.send(:notice, self.should)
    end

  end

  newparam(:name, :namevar => true) do
    desc 'The name of the job'
  end

  newparam(:wait) do
    desc "the agent we want to call"

    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:agent) do
    desc "the agent we want to call"
  end

  newparam(:action) do
    desc 'The action on the agent'
  end

  newparam(:filter, :array_matching => :all) do
    desc 'What filtering to apply'
    ourkeys = ['identity','class','compound']
    validate do |whatdidwegetgiven|
      whatdidwegetgiven.each do |k,v|
        raise ArgumentError, "Filter allowable hash keys are 'identity', 'class', 'compound'" unless ourkeys.member?(k)
      end
    end
    defaultto []
  end

  newparam(:parameters, :array_matching => :all) do
  end

  newparam(:optionhash, :array_matching => :all) do

  end
  newparam(:configfile) do
    desc 'What filtering to apply'
    defaultto '/etc/puppetlabs/puppet/client/cfg'

    validate do |config|
      raise ArgumentError, "#{config} is not an absolute path" unless File.absolute_path(config) == config
    end
  end

  newcheck(:refreshonly) do

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
