package  # hide from Pause
   HTML::FormHandler::Meta::Class;
use Moose;
extends 'Moose::Meta::Class';

=head1 NAME

HTML::FormHandler::Meta::Class

=head1 SYNOPSIS

Add metaclass to field_list attribute

=cut

has 'field_list' => ( is => 'rw', isa => 'ArrayRef', predicate => 'has_field_list' );

=head1 AUTHOR

Gerda Shank, gshank@cpan.org

=head1 COPYRIGHT

Same terms as Perl itself.

=cut

1;
