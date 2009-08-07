package HTML::FormHandler::Field::Minute;

use Moose;
extends 'HTML::FormHandler::Field::IntRange';
our $VERSION = '0.01';

has '+range_start'  => ( default => 0 );
has '+range_end'    => ( default => 59 );
has '+label_format' => ( default => '%02d' );

=head1 NAME

HTML::FormHandler::Field::Minute - input range from 0 to 59

=head1 DESCRIPTION

Generate a select list for entering a minute value.
Widget type is 'select'.

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;
1;
