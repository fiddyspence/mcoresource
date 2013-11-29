exec { '/bin/true': }
~>
mco { 'the thing':
  agent => 'puppet',
  action => 'runonce',
  filter => '',
}
