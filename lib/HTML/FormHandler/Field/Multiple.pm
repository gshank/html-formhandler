package HTML::FormHandler::Field::Multiple;

use Moose;
extends 'HTML::FormHandler::Field::Select';
our $VERSION = '0.01';

has '+multiple' => ( default => 1 );
has '+size'     => ( default => 5 );

sub options
{
   my $self    = shift;
   my @options = $self->SUPER::options(@_);
   my $value   = $self->value;

   # This places the currently selected options at the top of the list
   # Makes the drop down lists a bit nicer
   if ( @options && defined $value ) {
      my %selected = map { $_ => 1 } ref($value) eq 'ARRAY' ? @$value : ($value);

      my @out = grep { $selected{ $_->{value} } } @options;
      push @out, grep { !$selected{ $_->{value} } } @options;

      return wantarray ? @out : \@out;
   }
   return wantarray ? @options : \@options;
}

=head1 NAME

HTML::FormHandler::Field::Multiple - Select one or more options

=head1 DESCRIPTION

This inherits from the Select field,
and sets the "multiple" flag true to accept multiple options.

The currently selected items will be put at the top of the list.
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
