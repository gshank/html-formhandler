package HTML::FormHandler::Field::Duration;

use Moose;
extends 'HTML::FormHandler::Field::Compound';
use DateTime;

our $VERSION = '0.01';

=head1 NAME

HTML::FormHandler::Field::Duration -  DateTime::Duration from HTML form values 

=head1 SubFields

Subfield names:

  years, months, weeks, days, hours, minutes, seconds, nanoseconds 

For example:

   has 'duration' => ( type => 'Compound' );
   has 'duration.hours' => ( type => 'Int', range_start => 0,
        range_end => 23 );
   has 'duration.minutes' => ( type => 'Int', range_start => 0,
        range_end => 59 );


=cut

sub validate 
{
    my ( $self ) = @_;

    my @dur_parms;
    foreach my $child ($self->fields)
    {
       unless ( $child->value =~ /^\d+$/ )
       {
          $self->add_error( "Invalid value for " . $self->label . " " . $child->label );
          next;
       }
       push @dur_parms, ($child->accessor => $child->value); 
    }

    # set the value
    my $duration = DateTime::Duration->new(@dur_parms);
    $self->value($duration);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

