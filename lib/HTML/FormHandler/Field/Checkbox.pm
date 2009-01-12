package HTML::FormHandler::Field::Checkbox;

use Moose;
extends 'HTML::FormHandler::Field::Boolean';
our $VERSION = '0.01';

has '+widget' => ( default => 'checkbox' );

__PACKAGE__->meta->make_immutable;

sub input_to_value {
    my $field = shift;

    $field->value( $field->input ? 1 : 0 );
}

sub value {
    my $field = shift;
    return $field->SUPER::value( @_ ) if @_;
    my $v = $field->SUPER::value;
    return defined $v ? $v : 0;
}


=head1 NAME

HTML::FormHandler::Field::Checkbox - A boolean checkbox field type

=head1 DESCRIPTION

This field is very similar to the Boolean field with the exception
that only true or false can be returned. Widget type is 'checkbox'.

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose;
1;
