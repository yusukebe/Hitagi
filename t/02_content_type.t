use strict;
use Test::More;

BEGIN { $ENV{'PLACK_ENV'} = 'development'; }

my $s = do {
    use Hitagi;
    get '/xml' => sub {
        my $res = res(200);
        $res->content_type('application/xml');
        $res->body( template('xml'));
        $res->finalize;
    };
    star;
};

my $res = $s->(
    { REQUEST_METHOD => 'GET', PATH_INFO => '/xml', HTTP_HOST => 'localhost' } );

is_deeply(
    $res,
    [
        200,
        [ 'Content-Type' => 'application/xml' ],
        ['<xml><root>content</root></xml>']
    ],
    'Handling XML content type is OK.',
);
done_testing;

__DATA__

@@ xml
<xml><root>content</root></xml>
