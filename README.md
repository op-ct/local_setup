# Local environment setup Bolt project



## Description

## Setup

### Requirements

* Puppet Bolt 3.0+: https://puppet.com/docs/bolt/latest/bolt.html
* sudo access to install commands as an admin user

### Installing ruby gems

On linux platforms:

    /opt/puppetlabs/bolt/bin/gem install --user-install -g gem.deps.rb --no-document

On Windows with the default install location:

    "C:/Program Files/Puppet Labs/Bolt/bin/gem.bat" install --user-install <GEM>


You 
    /opt/puppetlabs/bolt/bin/gem install --user-install cleanup
## Usage

```console

bolt plan run local_setup

```


