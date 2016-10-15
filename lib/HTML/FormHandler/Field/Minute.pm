package HTML::FormHandler::Field::Minute;
# ABSTRACT: input range from 0 to 59

use Moose;
extends 'HTML::FormHandler::Field::IntRange';

has '+range_start'  => ( default => 0 );
has '+range_end'    => ( default => 59 );
has '+label_format' => ( default => '%02d' );

=head1 DESCRIPTION

Generate a select list for entering a minute value.
Widget type is 'select'.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
