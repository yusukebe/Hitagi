use strict;
use Test::More;

BEGIN { $ENV{'PLACK_ENV'} = 'development'; }

my $app = do {
    use Hitagi;
    get '/' => 'index';
    star;
};

{
  my $res =
    $app->(
      { REQUEST_METHOD => 'GET', PATH_INFO => '/', HTTP_HOST => 'localhost' } );
  chomp $res->[2]->[0];
  is( $res->[2]->[0], 'Hello', 'Template rendering is OK.' );
}

{
    my $res = $app->(
        {
            REQUEST_METHOD => 'POST',
            PATH_INFO      => '/',
            HTTP_HOST      => 'localhost'
        }
    );
    is( $res->[0], 404, 'Handling 404 is OK.' );
}

done_testing;

__DATA__

@@ index
Hello
