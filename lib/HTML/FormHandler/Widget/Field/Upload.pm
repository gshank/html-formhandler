package HTML::FormHandler::Widget::Field::Upload;
# ABSTRACT: update field rendering widget

use Moose::Role;
use HTML::FormHandler::Render::Util ('process_attrs');

sub render {
    my ( $self, $result ) = @_;

    $result ||= $self->result;
    my $output;
    $output = '<input type="file" name="';
    $output .= $self->html_name . '"';
    $output .= ' id="' . $self->id . '"';
    $output .= process_attrs($self->attributes);
    $output .= ' />';
    return $self->wrap_field($result, $output);
}

use namespace::autoclean;
1;
