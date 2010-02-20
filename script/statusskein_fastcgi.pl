#!/usr/bin/env perl

use Catalyst::ScriptRunner;
Catalyst::ScriptRunner->run('App::StatusSkein::Web', 'FastCGI');

1;
