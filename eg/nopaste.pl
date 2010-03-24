use Hitagi;
use Data::UUID;

my $uuid_gen = Data::UUID->new;

set db => {
    connect_info => [ 'dbi:SQLite:','', '' ],
    schema       => qq{
        install_table entry => schema {
           pk 'id';
           columns qw/id body/;
        };
    }
};

db->do(q{CREATE TABLE entry ( id varchar, body text )});

get '/' => 'index';

post '/post' => sub {
    my $req  =  shift;
    my $body  = $req->param('body') or redirect( $req->base );
    my $uuid  = $uuid_gen->create_str;
    db->insert(
        entry => {
            id   => $uuid,
            body => $body,
        }
    );
    return redirect( $req->base . "entry/$uuid" );
};

get '/entry/{entry_id}' => sub {
    my ( $req, $args ) = @_;
    my $entry_id = $args->{entry_id};
    my $entry = db->single( entry => { id => $entry_id, } );
    return res(404,[],'Not Found')->finalize unless $entry;
    render( 'entry', { body => $entry->body } );
};

star;

__DATA__

@@ layout
<html>
<head><title>nopaste</title></head>
<body>
<h1><a href="<?= $base ?>">Yet Another nopaste</a></h1>
<div id="container"><?= content ?></div>
</body>
</html>

@@ index
<form action="<?= $base ?>post" method="post">
<p><textarea name="body" cols="60" rows="10"></textarea></p>
<p><input type="submit" value="no paste" /><p>
</form>

@@ entry
<pre>
<?= $body ?>
</pre>
