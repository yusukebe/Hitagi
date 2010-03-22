package Hitagi;
use strict;
use warnings;
our $VERSION = '0.01';
use Data::Section::Simple;
use Plack::Request;
use Plack::Response;
use Router::Simple;
use Text::MicroTemplate;

my $_ROUTER = Router::Simple->new;
my $_DATA;

sub app {
    sub {
        my $env = shift;
        if ( my $p = $_ROUTER->match($env) ) {
            my $req  = Plack::Request->new($env);
            my $code = $p->{action};
            if ( ref $code eq 'CODE' ){
                return &$code($req);
            }
            render($code);
        }
        else {
            [ 404, [], ['Not Found'] ];
        }
    };
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
    my ( $file, $args ) = @_;
    my $tmpl        = $_DATA->get_data_section($file);
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
    my $code =
      Text::MicroTemplate->new( template => $tmpl, package => caller )->code;
    my $builder =
      "sub { $args_string; Text::MicroTemplate::encoded_string( $code->() ); }";
    local $@;
    my $coderef = ( eval $builder );
    die "Can't compile template '$file' : $@" if $@;
    handle_html( $coderef->($args)->as_string );
}

sub handle_html {
    my ( $body, $content_type ) = @_;
    $content_type ||= 'text/html';
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
    *{"${caller}::get"}    = sub { get(@_) };
    *{"${caller}::render"} = sub { render(@_) };
    *{"${caller}::res"} = sub { Plack::Response->new(@_) };
    if ( $ENV{'PLACK_ENV'} ){
        *{"${caller}::star"} = \&app;
    }else{
        *{"${caller}::star"}   = sub { run(@_) };
        *{"${caller}::star"}   = sub { run_as_cgi() } if $filename =~ /\.cgi$/;
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
