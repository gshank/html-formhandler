package HTML::FormHandler::Field::Hour;

use Moose;
extends 'Form::Processor::Field::IntRange';
our $VERSION = '0.03';

has '+range_start' => ( default => 0 );
has '+range_end' => ( default => 23 );

__PACKAGE__->meta->make_immutable;

=head1 NAME

HTML::FormHandler::Field::Hour - accept integer from 0 to 23

=head1 DESCRIPTION

Enter an integer from 0 to 23 hours.

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose;
1;
