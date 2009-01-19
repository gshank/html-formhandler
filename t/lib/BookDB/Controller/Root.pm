package BookDB::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

MyApp::Controller::Root - Root Controller for MyApp

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 default

=cut

sub base : Chained('/') PathPart('') CaptureArgs(0)
{
   my ( $self, $c ) = @_;
}

sub def : Chained('base') PathPart('') Args
{
    my ( $self, $c ) = @_;
    return $c->controller('Book')->do_list($c);
}


=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') { }

=head1 AUTHOR

Gerda Shank

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
