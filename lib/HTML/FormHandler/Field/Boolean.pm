package HTML::FormHandler::Field::Boolean;
# ABSTRACT: a true or false field

use Moose;
extends 'HTML::FormHandler::Field::Checkbox';
our $VERSION = '0.03';

=head1 DESCRIPTION

This field returns 1 if true, 0 if false.  The widget type is 'Checkbox'.
Similar to Checkbox, except only returns values of 1 or 0.

=cut

sub value {
    my ( $self, @params ) = @_;

    my $v = $self->next::method( @params );

    return $v ? 1 : 0;
}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
