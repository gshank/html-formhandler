package HTML::FormHandler::Field::Checkbox;

use Moose;
extends 'HTML::FormHandler::Field';
our $VERSION = '0.01';

=head1 NAME

HTML::FormHandler::Field::Checkbox - A checkbox field type

=head1 DESCRIPTION

This field is very similar to the Boolean Widget except that this 
field allows other positive values besides 1. Since unselected 
checkboxes do not return a parameter, fields with Checkbox type 
will always be set to the 'input_without_param' default if they 
do not appear in the form.

=head2 widget

checkbox

=cut

has '+widget' => ( default => 'checkbox' );
has 'checkbox_value' => ( is => 'rw', default => 1 );

=head2 input_without_param

If the checkbox is not checked, it will be set to the value
of this attribute (the unchecked value). Default = 0

=cut

has '+input_without_param' => ( default => 0 );

__PACKAGE__->meta->make_immutable;

sub value {
    my $field = shift;
    return $field->SUPER::value( @_ ) if @_;
    my $v = $field->SUPER::value;
    return defined $v ? $v : 0;
}


=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose;
1;
