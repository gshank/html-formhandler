package HTML::FormHandler::Widget::Field::Role::HTMLAttributes;
# ABSTRACT: apply HTML attributes

=head1 SYNOPSIS

Deprecated. Only here for interim compatibility, to provide
'_add_html_attributes' method. Will be removed in the future.

=cut

use Moose::Role;
use HTML::FormHandler::Render::Util ('process_attrs');

sub _add_html_attributes {
    my $self = shift;
    my $output = process_attrs( $self->attributes );
    return $output;
}

1;
