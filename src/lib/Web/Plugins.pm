package Web::Plugins;

use strict;
use warnings;
use PluginsDirs;

grep { require $_ } PluginsDirs->autoload_files;

1;
