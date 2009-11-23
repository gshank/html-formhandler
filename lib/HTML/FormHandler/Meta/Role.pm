package    # hide from Pause
    HTML::FormHandler::Meta::Role;

use Moose::Role;

=head1 NAME

HTML::FormHandler::Meta::Role

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

=head1 AUTHOR

Gerda Shank, gshank@cpan.org

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

use namespace::autoclean;
1;
