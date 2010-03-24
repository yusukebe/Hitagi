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
<p><a href="<?= $base ?>hi">hi</a></p>

@@ hi
<h1>message : <?= $message ?></h1>
<p><a href="<?= $base ?>">back</a></p>

@@ layout
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <title>Hitagi</title>
  <link rel="stylesheet" type="text/css" href="<?= $base ?>static/screen.css" />
</head>
<body>
  <div class="container">
  <?= content ?>
  <br /><hr />
  <address>This content is made by Hitagi</address>
  </div>
</body>
</html>
