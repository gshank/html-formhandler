package HTML::FormHandler::Widget::Form::Role::HTMLAttributes;

use Moose::Role;

sub html_form_tag {
    my $self = shift;

    my @attr_accessors = (
        [ action  => 'action' ],
        [ id      => 'name' ],
        [ method  => 'http_method' ],
        [ enctype => 'enctype' ],
        [ class   => 'css_class' ],
        [ style   => 'style' ],
    );

    my $output = '<form';
    foreach my $attr_pair (@attr_accessors) {
        my $accessor = $attr_pair->[1];
        if ( my $value = $self->$accessor ) {
            $output .= ' ' . $attr_pair->[0] . '="' . $value . '"';
        }
    }
    $output .= " >\n";
    return $output;
}

no Moose::Role;
1;
