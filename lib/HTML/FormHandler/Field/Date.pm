package HTML::FormHandler::Field::Date;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::DateTime';

use DateTime;
our $VERSION = '0.01';

=head1 NAME

HTML::FormHandler::Field::Date

=head1 DESCRIPTION

This is a date field that predefines day, month, and year subfields.  
It has two additional attributes, 'year_start' and 'year_end'.

=head1 AUTHORS

Gerda Shank

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

has '+widget' => ( default => 'compound' );

has 'year_start' => ( isa => 'Int', is => 'rw', default => '2002'  );
has 'year_end' => ( isa => 'Int', is => 'rw', default => '2012' );

has_field 'year' => ( type => 'Integer' );
has_field 'month' => ( type => 'Integer', range_start => 1,
     range_end => 12 );
has_field 'day' => ( type => 'Integer', range_start => 1,
     range_end => 31 ); 


sub validate 
{
    my ( $self ) = @_;

    # here there should be validation of the specific day ranges
    # for the selected month
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

