package HTML::FormHandler::Widget::Field::Captcha;
# ABSTRACT: Captcha field rendering widget

use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

sub render {
    my $self = shift;
    my $result = shift || $self->result;
    return '' if $self->widget eq 'no_widget';

    my $output .= '<img src="' . $self->form->captcha_image_url . '"/>';
    $output .= '<input id="' . $self->id . '" name="';
    $output .= $self->html_name . '"';
    $output .= process_attrs($self->element_attributes);
    $output .= '/>';

    return $self->wrap_field( $result, $output );
}

1;
