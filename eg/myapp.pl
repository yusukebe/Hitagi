#!/usr/bin/perl
use Hitagi;

get '/'     => 'index';
get '/text' => sub { 'Hello' };
get '/hi'   => sub { render( 'hi', { message => 'This is message' } ) };
get '/xml'  => sub {
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
@@ index
<h1>welcome</h1>
<small><a href="<?= $base ?>hi">hi</a></small>

@@ hi
<h1>message : <?= $message ?></h1>
<small><a href="<?= $base ?>">back</a></small>

@@ layout
<html>
</head><title>Hitagi</title></head>
<body>
<?= content ?>
<br /><hr />
<address>This content is made by Hitagi</address>
</body>
</html>
