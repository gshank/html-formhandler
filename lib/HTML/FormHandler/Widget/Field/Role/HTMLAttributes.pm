package HTML::FormHandler::Widget::Field::Role::HTMLAttributes;
# ABSTRACT: apply HTML attributes

use Moose::Role;

sub _add_html_attributes {
    my $self = shift;

    my $output = q{};
    for my $attr ( 'readonly', 'disabled', 'style', 'title', 'tabindex' ) {
        $output .= ( $self->$attr ? qq{ $attr="} . $self->$attr . '"' : '' );
    }
    $output .= ($self->javascript ? ' ' . $self->javascript : '');
    if( $self->input_class ) {
        $output .= ' class="' . $self->input_class . '"';
    }
    return $output;
}

1;
