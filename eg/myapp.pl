use Hitagi;

get '/'      => 'index.mt';
get '/hello' => sub {
    my $req = shift;
    my $name = $req->param('name') || 'no name';
    render( 'hello.mt', { name => $name } );
};

star;

__DATA__

@@ index.mt
<h1>hello</h1>
<form action="/hello">
<input type="text" name="name" />
<input type="submit" />
</form>

@@ hello.mt
<h1>welcome <?= $name ?></h1>

