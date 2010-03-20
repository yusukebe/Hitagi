package Hitagi;
use strict;
use warnings;
our $VERSION = '0.01';
use Data::Section::Simple;
use Plack::Request;
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
            if ( ref $code eq 'CODE' ) {
                &$code($req);
            }
            else {
                render($code);
            }
        }
        else {
            [ 404, [], ['Not Found'] ];
        }
    }
}

sub any {
    my ( $pattern, $code ) = @_;
    $_ROUTER->connect( $pattern, { action => $code } );
}

sub get {
    any( $_[0], $_[1] );
}

sub post {
    any( $_[0], $_[1] );
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
    my $body = $coderef->($args);
    return [ 200, [], [$body] ];
}

sub builder {
    my ( $tmt, $args ) = @_;
    my $code = $tmt->code;
}

sub run {
    require Plack::Runner;
    my $runner = Plack::Runner->new;
    $runner->parse_options(@ARGV);
    $runner->run(&app);
}

sub import {
    strict->import;
    warnings->import;
    no strict 'refs';
    no warnings 'redefine';
    my $caller = caller;
    $_DATA = Data::Section::Simple->new($caller);
    *{"${caller}::get"}    = sub { get(@_) };
    *{"${caller}::render"} = sub { render(@_) };
    *{"${caller}::star"}   = sub { run() };
}

1;

__END__

=head1 NAME

Hitagi - Shall we talk about stars and micro web application framework.

=head1 SYNOPSIS

  use Hitagi;
  get '/' => render_text('Hi');
  star;

=head1 DESCRIPTION

Hitagi is

=head1 AUTHOR

Yusuke Wada E<lt>yusuke at kamawada.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
