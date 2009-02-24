package BookDB;

use strict;
use Catalyst ('-Debug',
              'Static::Simple',
);

our $VERSION = '0.02';

BookDB->config( name => 'BookDB' );

BookDB->setup;


=head1 NAME

BookDB - Catalyst based application

=head1 SYNOPSIS

    script/bookdb_server.pl

=head1 DESCRIPTION

Catalyst based application.

=head1 METHODS

=over 4


=item chained_uri_for

=cut

sub this_chained_uri 
{
   my $c = shift;
   return $c->uri_for($c->action,$c->req->captures,@_);    
}

sub chained_uri_for
{
   my ($c, $controller, $action, $captures) = @_;
   return $c->uri_for($c->controller($controller)->action_for($action),
            $captures );
}

=back

=head1 AUTHOR

Gerda Shank

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
