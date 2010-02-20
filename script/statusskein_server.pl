#!/usr/bin/env perl

BEGIN { $ENV{CATALYST_SCRIPT_GEN} = 40; }

use Catalyst::ScriptRunner;
Catalyst::ScriptRunner->run('App::StatusSkein::Web', 'Server');

1;
