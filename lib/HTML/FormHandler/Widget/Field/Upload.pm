package HTML::FormHandler::Widget::Field::Upload;

use Moose::Role;
with 'HTML::FormHandler::Widget::Field::Role::HTMLAttributes';

sub render {
    my ( $self, $result ) = @_;

    $result ||= $self->result;
    my $output;
    $output = '<input type="file" name="';
    $output .= $self->html_name . '"';
    $output .= ' id="' . $self->id . '"';
    $output .= $self->_add_html_attributes;
    $output .= ' />';
    return $self->wrap_field($result, $output);
}

use namespace::autoclean;
1;
