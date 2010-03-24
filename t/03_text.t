use strict;
use Test::More;

BEGIN { $ENV{'PLACK_ENV'} = 'development'; }

my $s = do {
    use Hitagi;
    get '/' => sub { 'Hello' };
    star;
};

my $res = $s->(
    { REQUEST_METHOD => 'GET', PATH_INFO => '/', HTTP_HOST => 'localhost' } );
chomp $res->[2]->[0];
is($res->[2]->[0],'Hello','Text style rendering is OK.');

done_testing;

