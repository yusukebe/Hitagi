#!/usr/bin/perl
use Hitagi;
use MyApp;

set 'view', { wrapper => [qw/header.mt content footer.mt/] };
set 'model', { api => MyApp->new };

get '/'    => 'index.mt';
get '/text' => sub { 'Hello' };
get '/hi'  => sub { render( 'hi.mt', { message => 'Hi' } ) };
get '/xml' => sub {
    my $res = res(200);
    $res->content_type('application/xml');
    $res->body('<xml><root>content</root></xml>');
    $res->finalize;
};
get '/comment/:id' => sub {
    my ( $req, $args ) = @_;
    "Your comment id is $args->{id}";
};

star;

__DATA__
@@ index.mt
<h1>welcome</h1>

@@ hi.mt
<h1>message : <?= $message ?></h1>

@@ header.mt
<html>
</head><title>title</title></head>
<body>

@@ footer.mt
<address>This content is made by Hitagi</address>
</body>
</html>
