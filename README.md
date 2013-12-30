This is the mcoresource module. It provides a core type and provider for triggering mcollective agent actions from a Puppet Catalog during a Catalog apply action on an agent...

Consider the following resource chain:

    exec { '/bin/true': }
      ~>
    mco { 'the thing':
      agent      => 'package',
      action     => 'upgrade',
      filter     => { 
                       'identity' => ['node1','node2','/somenodeswithacommonname/'],
                       'compound' => 'sysctl("vm.swappiness").value=50',
                       'class'    => ['aclass::withasubclass'],
                    }          
      configfile => '/var/lib/peadmin/.mcollective',
      wait       => true,
      parameters => { 'package' => 'openssl' }
    }

The mco resource is set to `refreshonly => true` by default, so unless it's triggered by a refresh event from another resource nothing will happen.

If triggered, the mcollective RPC agent puppet, with the action runonce will be triggered (filtering works for classes and identity - watch for magic later - maybe version 0.0.2) using the configuration file at `configfile`

Other parameters:

    wait: whether to hold for RPC responses
    parameters: other options to send the mcollective agent (e.g. the status action on the package agent requires package=foo)
    optionhash: other mcollective client options - will override any defaults (e.g. optionshash => { 'theoption' => 'thevalue' })


License
-------
Apache 2.0

Contact
-------
chris.spence@puppetlabs.com
