package HTML::FormHandler::Widget::Field::Repeatable;
# ABSTRACT: repeatable field widget
use Moose::Role;
with 'HTML::FormHandler::Widget::Field::Compound';

=head1 SYNOPSIS

Renders a repeatable field

=cut

has 'wrap_repeatable_element_method' => (
     traits => ['Code'],
     is     => 'ro',
     isa    => 'CodeRef',
     handles => { 'wrap_repeatable_element' => 'execute_method' },
);

sub render_subfield {
    my ( $self, $result, $subfield ) = @_;

    my $subresult = $result->field( $subfield->name );

    return "" unless $subresult
        or ( $self->has_flag( "is_repeatable")
            and $subfield->name < $self->num_when_empty
        );

    my $output = $subfield->render($subresult);
    if ( $self->wrap_repeatable_element_method ) {
        $output = $self->wrap_repeatable_element($output, $subfield->name);
    }
    return $output;
}

use namespace::autoclean;
1;
