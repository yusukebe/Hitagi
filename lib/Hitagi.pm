package Hitagi;
use strict;
use warnings;
our $VERSION = '0.01';
use Data::Section::Simple;
use Plack::Request;
use Plack::Response;
use Router::Simple;
use Text::MicroTemplate;
use File::Slurp qw/slurp/;

my $_ROUTER = Router::Simple->new;
my ( $_DATA, $_BASE, $_DB );

sub app {
    sub {
        my $env = shift;
        my $req = Plack::Request->new($env);
        $_BASE = $req->base unless $_BASE;
        if ( my $p = $_ROUTER->match($env) ) {
            my $code = $p->{action};
            if ( ref $code eq 'CODE' ) {
                my $res = &$code( $req, $p->{args} );
                return $res if ref $res eq 'ARRAY';
                return handle_html($res);
            }
            render($code);
        }
        else {
            [ 404, [], ['Not Found'] ];
        }
    };
}

sub set {
    my ( $name, $args ) = @_;
    set_db($args) if $name eq 'db';
}

sub any {
    my ( $pattern, $code, $method ) = @_;
    $_ROUTER->connect( $pattern, { action => $code } , { method => $method } );
}

sub get {
    any( $_[0], $_[1] , 'GET' );
}

sub post {
    any( $_[0], $_[1] , 'POST' );
}

sub render {
    my ( $name, $args ) = @_;
    $args ||= {};
    my $template = code($name) or return [ 500, [], ['Internal Server Error'] ];
    my $code = $template;
    if( my $layout = code('layout') ){
        $code .= ";sub content { Text::MicroTemplate::encoded_string $template->() };";
        $code .=  $layout;
    }
    $args->{base} = $_BASE;
    my $args_string = args_string($args);
    no warnings; #XXX
    local $@;
    my $renderer = eval <<  "..." or die $@;
sub {
    my \$args = shift; $args_string;
    $code->();
};
...
    handle_html( $renderer->($args), $args->{content_type} || 'text/html' );
}

sub template {
    my $name = shift;
    my $template = '';
    $template = $_DATA->get_data_section($name);
    local $@;
    eval{
        $template = slurp($name) unless $template;
    };
    chomp $template if $template;
    return $template;
}

sub code {
    my $name     = shift;
    my $template = template( $name ) or return;
    my $mt       = Text::MicroTemplate->new( template => $template );
    my $code     = $mt->code;
    return $code;
}

# stolen from TMT::Extended
sub args_string {
    my $args        = shift;
    my $args_string = '';
    for my $key ( keys %{ $args || {} } ) {
        unless ( $key =~ /^[a-zA-Z_][a-zA-Z0-9_]*$/ ) {
            die qq{Invalid template args key name: "$key"};
        }
        if ( ref( $args->{$key} ) eq 'CODE' ) {
            $args_string .= qq{my \$$key = \$args->{$key}->();\n};
        }
        else {
            $args_string .= qq{my \$$key = \$args->{$key};\n};
        }
    }
    $args_string;
}


sub set_db {
    my ( $args ) = @_;
    my $schema = $args->{schema} || '';
    local $@;
    package DB::Schema;
    use DBIx::Skinny::Schema;
    eval $schema;
    1;
    die $@ if $@;
    package DB;
    use DBIx::Skinny;
    1;
    $_DB = DB->new(
        {
            dsn             => $args->{connect_info}[0] || '',
            username        => $args->{connect_info}[1] || '',
            password        => $args->{connect_info}[2] || '',
            connect_options => { AutoCommit => 1 },
        }
    );
}

sub db { return $_DB };

sub handle_html {
    my ( $body, $content_type ) = @_;
    $content_type ||= 'text/plain';
    return [
        200,
        [ 'Content-Length' => length $body, 'Content-Type' => $content_type ],
        [$body]
    ];
}

sub run {
    require Plack::Runner;
    my $runner = Plack::Runner->new;
    $runner->parse_options(@ARGV);
    $runner->run(&app);
}

sub run_as_cgi {
    require Plack::Handler::CGI;
    Plack::Handler::CGI->new->run(&app);
}

sub import {
    strict->import;
    warnings->import;
    no strict 'refs';
    no warnings 'redefine';
    my ( $caller, $filename ) = caller;
    $_DATA = Data::Section::Simple->new($caller);
    my @functions = qw/get post render set db template/;
    for my $function (@functions) {
        *{"${caller}\::$function"} = \&$function;
    }
    *{"${caller}::res"} = sub { Plack::Response->new(@_) };
    *{"${caller}::redirect"} =
      sub { return [ 302, [ 'Location' => shift ], [] ] };
    if ( $ENV{'PLACK_ENV'} ) {
        *{"${caller}::star"} = \&app;
    }
    else {
        *{"${caller}::star"} = sub { run(@_) };
        *{"${caller}::star"} = sub { run_as_cgi() }
          if $filename =~ /\.cgi$/;
    }
}

1;

__END__

=head1 NAME

Hitagi - Shall we talk about stars and micro web application frameworks.

=head1 SYNOPSIS

In myapp.pl

  use Hitagi;
  get '/' => sub { 'index.mt', render({ message => 'Hi' }) };
  star;

  __DATA__

  @@index.mt
  <h1>message : <?= $message ?></h1>

Run

  ./myapp.pl

=head1 DESCRIPTION

Hitagi is yet another micro web application framework
using Plack::Request, Router::Simple, and Text::MicroTemplate.

=head1 AUTHOR

Yusuke Wada E<lt>yusuke at kamawada.comE<gt>

=head1 SEE ALSO

L<Mojolicious::Lite>, L<Dancer>, L<MojaMoja>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
