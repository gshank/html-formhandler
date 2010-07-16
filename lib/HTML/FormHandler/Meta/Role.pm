package    # hide from Pause
    HTML::FormHandler::Meta::Role;
# ABSTRACT: field_list and apply_list

use Moose::Role;

=head1 SYNOPSIS

Add metaclass to field_list attribute

=cut

has 'field_list' => (
    traits    => ['Array'],
    is        => 'rw',
    isa       => 'ArrayRef',
    default   => sub { [] },
    handles  => {
        add_to_field_list => 'push',
        clear_field_list => 'clear',
        has_field_list => 'count',
    }
);

has 'apply_list' => (
    traits    => ['Array'],
    is        => 'rw',
    isa       => 'ArrayRef',
    default   => sub { [] },
    handles  => {
        add_to_apply_list => 'push',
        has_apply_list => 'count',
        clear_apply_list => 'clear',
    }
);

use namespace::autoclean;
1;
