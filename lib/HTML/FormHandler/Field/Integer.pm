package HTML::FormHandler::Field::Integer;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';
our $VERSION = '0.02';

has '+size' => ( default => 8 );

apply( [
   { transform => sub {
      my $value = shift;
      $value =~ s/^\+//;
      return $value;
   }},
   { check => sub { $_[0] =~ /^-?\d+$/ },
     message => 'Value must be an integer'
   } ]
);


=head1 NAME

HTML::FormHandler::Field::Integer - validate an integer value

=head1 DESCRIPTION

This accpets a positive or negative integer.  Negative integers may
be prefixed with a dash.  By default a max of eight digits are accepted.
Widget type is 'text'.

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;
1;
