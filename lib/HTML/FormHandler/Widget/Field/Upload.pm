package HTML::FormHandler::Widget::Field::Upload;

use Moose::Role;

sub render {
    my ( $self, $result ) = @_;

    $result ||= $self->result;
    my $output;
    $output = '<input type="file" name="';
    $output .= $self->html_name . '"';
    $output .= ' id="' . $self->id . '"/>';
    return $self->wrap_field($result, $output);
}

use namespace::autoclean;
1;
