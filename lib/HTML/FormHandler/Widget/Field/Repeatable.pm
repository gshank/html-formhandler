package HTML::FormHandler::Widget::Field::Repeatable;
# ABSTRACT: repeatable field widget

use Moose::Role;
with 'HTML::FormHandler::Widget::Field::Compound';

sub render_subfield {
    my ( $self, $result, $subfield ) = @_;
    my $subresult = $result->field( $subfield->name );

    return "" unless $subresult
        or ( $self->has_flag( "is_repeatable")
            and $subfield->name < $self->num_when_empty
        );

    return $subfield->render($subresult);
}

use namespace::autoclean;
1;
