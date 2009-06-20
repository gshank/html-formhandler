package HTML::FormHandler::Field::DateTime;

use Moose;
extends 'HTML::FormHandler::Field::Compound';

use DateTime;
our $VERSION = '0.03';

=head1 NAME

HTML::FormHandler::Field::DateTime

=head1 DESCRIPTION

This is a compound field that uses modified field names for the 
sub fields instead of using a separate sub-form. Widget type is 'compound'.

If you want to use drop-down select boxes for your DateTime, you
can use fields like:

    has_field 'my_date' => ( type => 'DateTime' );
    has_field 'my_date.month' => ( type => 'Month' );
    has_field 'my_date.day' => ( type => 'MonthDay' );
    has_field 'my_date.year' => ( type => 'Year' );
    has_field 'my_date.hour' => ( type => 'Hour' );
    has_field 'my_date.minute' => ( type => 'Minute' );

If you want simple input fields:

    has_field 'my_date' => ( type => 'DateTime' );
    has_field 'my_date.month' => ( type => 'Integer', range_start => 1,
         range_end => 12 );
    has_field 'my_date.day' => ( type => 'Integer', range_start => 1,
         range_end => 31 ); 

=head1 AUTHORS

Gerda Shank

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

has '+widget' => ( default => 'compound' );

sub validate 
{
    my ( $self ) = @_;

    my @dt_parms;
    foreach my $child ($self->fields)
    {
       next unless $child->value;
       push @dt_parms, ($child->accessor => $child->value); 
    }

    # set the value
    my $dt = DateTime->new(@dt_parms);
    $self->value($dt);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

