#!/usr/bin/perl
use Hitagi;

get '/'    => 'index.mt';
get '/text' => sub { 'Hello' };
get '/hi'  => sub { render( 'hi.mt', { message => 'Hi' } ) };
get '/xml' => sub {
    my $res = res(200);
    $res->content_type('application/xml');
    $res->body('<xml><root>content</root></xml>');
    $res->finalize;
};

star;

__DATA__
@@ index.mt
<h1>welcome</h1>

@@ hi.mt
<h1>message : <?= $message ?></h1>

