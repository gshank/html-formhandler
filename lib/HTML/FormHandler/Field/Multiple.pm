package HTML::FormHandler::Field::Multiple;
# ABSTRACT: multiple select list
use strict;
use warnings;
use Moose;
extends 'HTML::FormHandler::Field::Select';
our $VERSION = '0.01';

=head1 DESCRIPTION

This is a convenience field that inherits from the Select field and
pre-sets some attributes. It sets the 'multiple' flag,
sets the 'size' attribute to 5, and sets the 'sort_options_method' to
move the currently selected options to the top of the options list.

=cut

has '+multiple' => ( default => 1 );
has '+size'     => ( default => 5 );
has '+sort_options_method' => ( default => sub { \&default_sort_options } );

sub default_sort_options {
    my ( $self, $options ) = @_;

    return $options unless scalar @$options && defined $self->value;
    my $value = $self->deflate($self->value);
    return $options unless scalar @$value;
    # This places the currently selected options at the top of the list
    # Makes the drop down lists a bit nicer
    my %selected = map { $_ => 1 } @$value;
    my @out = grep { $selected{ $_->{value} } } @$options;
    push @out, grep { !$selected{ $_->{value} } } @$options;
    return \@out;
}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
