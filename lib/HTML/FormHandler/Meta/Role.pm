package  # hide from Pause
   HTML::FormHandler::Meta::Role;

use Moose::Role;
use MooseX::AttributeHelpers;

=head1 NAME

HTML::FormHandler::Meta::Role

=head1 SYNOPSIS

Add metaclass to field_list attribute

=cut

has 'field_list' => (
   metaclass => 'Collection::Array',
   is => 'rw',
   isa => 'ArrayRef',
   default => sub { [] },
   provides => {
      'push' => 'add_to_field_list',
      'clear' => 'clear_field_list',
      'empty' => 'has_field_list',
   }
);

has 'apply_list' => (
   metaclass => 'Collection::Array',
   is => 'rw',
   isa => 'ArrayRef',
   default => sub { [] },
   provides => {
      'push' => 'add_to_apply_list',
      'empty' => 'has_apply_list',
      'clear' => 'clear_apply_list',
   }
);


=head1 AUTHOR

Gerda Shank, gshank@cpan.org

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose::Role;
1;
