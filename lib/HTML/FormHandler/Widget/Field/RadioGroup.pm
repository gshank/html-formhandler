package HTML::FormHandler::Widget::Field::RadioGroup;
# ABSTRACT: radio group rendering widget
use Moose::Role;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

=head1 SYNOPSIS

Renders a radio group (from a 'Select' field);

Tags: radio_br_after

=cut

sub type_attr { 'radio' }

sub render {
    my ( $self, $result ) = @_;
    $result ||= $self->result;
    die "No result for form field '" . $self->full_name . "'. Field may be inactive." unless $result;
    my $output = $self->render_element( $result );
    return $self->wrap_field( $result, $output );
}

sub render_element {
    my ( $self, $result ) = @_;
    $result ||= $self->result;

    my $output = '';
    $output .= "<br />" if $self->get_tag('radio_br_after');

    foreach my $option ( @{ $self->{options} } ) {
        if ( my $label = $option->{group} ) {
            $label = $self->_localize( $label ) if $self->localize_labels;
            my $attr = $option->{attributes} || {};
            my $attr_str = process_attrs($attr);
            my $lattr = $option->{label_attributes} || {};
            my $lattr_str= process_attrs($lattr);
            $output .= qq{\n<div$attr_str><label$lattr_str>$label</label>};
            foreach my $group_opt ( @{ $option->{options} } ) {
                $output .= $self->render_option( $group_opt, $result );
            }
            $output .= qq{\n</div>};
        }
        else {
            $output .= $self->render_option( $option, $result );
        }
        $output .= '<br />' if $self->get_tag('radio_br_after');
    }
    $self->reset_options_index;
    return $output;
}

sub render_option {
    my ( $self, $option, $result ) = @_;

    $result ||= $result;
    my $rendered_widget = $self->render_radio( $result, $option );
    my $output = $self->wrap_radio( $rendered_widget, $option->{label} );
    $self->inc_options_index;
    return $output;
}

sub render_wrapped_option {
    my ( $self, $option, $result ) = @_;

    $result ||= $self->result;
    my $output = $self->render_option( $option, $result );
    return $self->wrap_field( $result, $output );
}

sub render_radio {
    my ( $self, $result, $option ) = @_;
    $result ||= $self->result;

    my $value = $option->{value};
    my $id = $self->id . "." . $self->options_index;
    my $output = '<input type="radio" name="'
        . $self->html_name . qq{" id="$id" value="}
        . $self->html_filter($value) . '"';
    $output .= ' checked="checked"'
        if $result->fif eq $value;
    $output .= process_attrs($option->{attributes});
    $output .= ' />';
    return $output;
}

sub wrap_radio {
    my ( $self, $rendered_widget, $option_label ) = @_;

    my $id = $self->id . "." . $self->options_index;
    my $for = qq{ for="$id"};

    # use "simple" label attributes for inner label
    my @label_class = ('radio');
    push @label_class, 'inline' if $self->get_tag('inline');
    my $lattrs = process_attrs( { class => \@label_class } );

    # return wrapped radio, either on left or right
    my $label = $self->_localize($option_label);
    my $output = '';
    if ( $self->get_tag('label_left') ) {
        $output = qq{<label$lattrs$for>\n$label\n$rendered_widget</label>};
    }
    else {
        $output = qq{<label$lattrs$for>$rendered_widget\n$label\n</label>};
    }
    if ( $self->get_tag('radio_element_wrapper') ) {
        $output = qq{<div class="radio">$output</div>};
    }
    return $output;
}

1;
