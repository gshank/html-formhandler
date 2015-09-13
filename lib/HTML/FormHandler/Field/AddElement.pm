package HTML::FormHandler::Field::AddElement;
# ABSTRACT: Field to support repeatable javascript add
use strict;
use warnings;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Display';
use HTML::FormHandler::Render::Util ('process_attrs');

=head1 NAME

HTML::FormHandler::Field::AddElement

=head1 SYNOPSIS

EXAMPLE field for rendering an AddElement field for
doing javascript additions of repeatable elements.

You probably want to make your own.

The main requirements are that the button have 1) the
'add_element' class, 2) a 'data-rep-id' attribute that
contains the id of the repeatable to which you want to
add an element.

=head1 ATTRIBUTES

    has_field 'add_element' => ( type => 'AddElement', repeatable => 'foo',
        value => 'Add another foo',
    );

=head2 repeatable

Requires the name of a Repeatable sibling field.

=head2 value

The value of the button that's rendered, 'Add Element' by default.

=cut

has 'repeatable' => ( is => 'rw', isa => 'Str', required => 1 );
has '+do_wrapper' => ( default => 1 );
has '+value'  => ( default => 'Add Element' );

sub build_render_method {
    return sub {
        my ( $self, $result ) = @_;
        $result ||= $self->result;

        my $rep_field = $self->parent->field($self->repeatable);
        die "Invalid repeatable name in field " . $self->name unless $rep_field;
        my $value = $self->html_filter($self->_localize($self->value));
        my $attrs = $self->element_attributes($result);
        push @{$attrs->{class}}, ( 'add_element', 'btn' );
        $attrs->{'data-rep-id'} = $rep_field->id;
        $attrs->{id} = $self->id;
        my $attr_str = process_attrs($attrs);
        my $wrapper_tag = $self->get_tag('wrapper_tag') || 'div';
        my $output = qq{<$wrapper_tag$attr_str>$value</$wrapper_tag>};
        $output = $self->wrap_field($self->result, $output);
        return $output;
    };
}

1;
