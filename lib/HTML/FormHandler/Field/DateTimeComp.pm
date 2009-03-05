package HTML::FormHandler::Field::DateTimeComp;

use Moose;
extends 'HTML::FormHandler::Field::Compound';
use DateTime;

our $VERSION = '0.02';

=head1 NAME

HTML::FormHandler::Field::DateTimeComp - Produces DateTime from HTML form values 

=cut

# override validate

sub validate {
    my ( $self ) = @_;


    # check for required has been done in 'validate_field' using
    # the presence of input as a check. Requires that the sub-fields
    # be named <parent_name>.<accessor>
    my @dt_parms;
    foreach my $child ($self->children)
    {
       unless ( $child->value =~ /^\d+$/ )
       {
          $self->add_error( "Invalid value for " . $self->label . " " . $child->label );
          next;
       }
       push @dt_parms, ($child->accessor => $child->value); 
    }
    # set the yalue
    my $dt = DateTime->new(@dt_parms);
    $self->value($dt);  # child values are already there

}


__PACKAGE__->meta->make_immutable;
no Moose;
1;

