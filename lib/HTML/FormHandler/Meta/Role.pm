package  # hide from Pause
   HTML::FormHandler::Meta::Role;

use Moose::Role;

=head1 NAME

HTML::FormHandler::Meta::Role

=head1 SYNOPSIS

Add metaclass to field_list attribute

=cut

has 'field_list' => ( is => 'rw', isa => 'ArrayRef', 
   predicate => 'has_field_list' );

=head1 AUTHOR

Gerda Shank, gshank@cpan.org

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose::Role;
1;
