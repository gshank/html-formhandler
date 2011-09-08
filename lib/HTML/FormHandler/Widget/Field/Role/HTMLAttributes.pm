package HTML::FormHandler::Widget::Field::Role::HTMLAttributes;
# ABSTRACT: apply HTML attributes

use Moose::Role;

sub _add_html_attributes {
    my $self = shift;

    my $output = q{};
    my $html_attr = { %{$self->html_attr} };
    for my $attr ( 'readonly', 'disabled', 'style', 'title', 'tabindex' ) {
        $html_attr->{$attr} = $self->$attr if !exists $html_attr->{$attr} && $self->$attr;
    }
    foreach my $attr ( sort keys %$html_attr ) {
        $output .= qq{ $attr="} . $html_attr->{$attr} . qq{"};
    }
    $output .= ($self->javascript ? ' ' . $self->javascript : '');
    if( $self->input_class ) {
        $output .= ' class="' . $self->input_class . '"';
    }
    return $output;
}

1;
