package HTML::FormHandler::Widget::Wrapper::None;
# ABSTRACT: wrapper that doesn't wrap

=head1 DESCRIPTION

This wrapper does nothing except return the 'bare' rendered form element,
as returned by the 'widget'. It does not add errors or anything else.

=cut

use Moose::Role;

sub wrap_field { "\n" . $_[2] }

use namespace::autoclean;
1;
