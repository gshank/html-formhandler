package HTML::FormHandler::Widget::Field::Submit;

use Moose::Role;

has 'no_render_label' => ( is => 'ro', lazy => 1, default => 1 );

sub render {
    my ( $self, $result ) = @_;

    $result ||= $self->result;
    my $output = '<input type="submit" name="';
    $output .= $self->html_name . '"';
    $output .= ' id="' . $self->id . '"';
    $output .= ' value="' . $self->value . '" />';
    return $self->wrap_field( $result, $output );
}

use namespace::autoclean;
1;
