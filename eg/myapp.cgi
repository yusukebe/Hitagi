#!/usr/bin/perl

use Hitagi;
get '/' => sub { render( 'index.mt', { message => 'Hi' } ) };
star;

__DATA__
@@ index.mt
<h1>message : <?= $message ?></h1>

