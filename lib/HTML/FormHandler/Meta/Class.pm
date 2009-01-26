package  # hide from Pause
    HTML::FormHandler::Meta::Class;
use Moose;
extends 'Moose::Meta::Class';

=head1 NAME

HTML::FormHandler::Meta::Class

=head1 SYNOPSIS

Adds a 'field_list' meta attribute for handling 'has_field'

=cut

has 'field_list' => ( is => 'rw' );

=head1 AUTHOR

Gerda Shank, gshank@cpan.org

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose;
1;
