package HTML::FormHandler::Widget::Form::Role::HTMLAttributes;
# ABSTRACT: set HTML attributes on the form tag

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

    my $html_attr = { %{$self->html_attr} };
    foreach my $attr_pair (@attr_accessors) {
        my $attr = $attr_pair->[0];
        my $accessor = $attr_pair->[1];
        if ( !exists $html_attr->{$attr} && defined( my $value = $self->$accessor ) ) {
            $html_attr->{$attr} = $self->$accessor;
        }
    }

    my $output = '<form';
    foreach my $attr ( sort keys %$html_attr ) {
        $output .= qq{ $attr="} . $html_attr->{$attr} . qq{"};
    }

    $output .= " >\n";
    return $output;
}

no Moose::Role;
1;
