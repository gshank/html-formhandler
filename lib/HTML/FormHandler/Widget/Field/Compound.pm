package HTML::FormHandler::Widget::Field::Compound;
# ABSTRACT: compound field widget

use Moose::Role;

sub render_subfield {
    my ( $self, $result, $subfield ) = @_;
    my $subresult = $result->field( $subfield->name );

    return "" unless $subresult;
    return $subfield->render( $subresult );
}

sub render {
    my ( $self, $result ) = @_;

    $result ||= $self->result;
    my $output = '';
    foreach my $subfield ( $self->sorted_fields ) {
        $output .= $self->render_subfield( $result, $subfield );
    }
    return $self->wrap_field( $result, $output );
}

use namespace::autoclean;
1;
