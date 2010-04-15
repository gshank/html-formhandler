package HTML::FormHandler::Widget::Field::Role::HTMLAttributes;

use Moose::Role;

sub _add_html_attributes {
    my $self = shift;

    my $output = q{};
    for my $attr ( 'readonly', 'disabled', 'style' ) {
        $output .= ( $self->$attr ? qq{ $attr="} . $self->$attr . '"' : '' );
    }
    $output .= ($self->javascript ? ' ' . $self->javascript : '');
    return $output;
}

1;
