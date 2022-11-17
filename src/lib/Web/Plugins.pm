package Web::Plugins;

use strict;
use warnings;
use Capture::Tiny qw(capture);

push @INC, split /\n/, capture {
    system qw(find /app/src/plugins -name lib);
};

1;
