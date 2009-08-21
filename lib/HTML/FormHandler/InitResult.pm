package HTML::FormHandler::InitResult;

use Moose::Role;

=head1 NAME

HTML::FormHandler::InitResult

=head1 SYNOPSIS

Internal class for initializing the result objects.

=cut

# _init is for building fields when 
# there is no initial object and no params
# formerly _init
sub _result_from_fields
{
   my $self = shift;
   $self->clear_result if $self->has_result;
   my $self_result = $self->result;
   for my $field ( $self->fields )
   {
      next if $field->inactive;
      my $result = $field->_result_from_fields;
      $result->parent($self_result);
      $self_result->add_result($result);
   }
   return $self_result;
}

# building fields from input (params) 
# formerly done in validate_field
sub _result_from_input
{
   my ( $self, $input, $exists ) = @_;

   # transfer the input values to the input attributes of the
   # subfields
   $self->clear_result if $self->has_result;
   return unless ( defined $input || $exists );
   my $self_result = $self->result;
   $self_result->_set_input($input);
   if ( ref $input eq 'HASH' ) {
      foreach my $field ( $self->fields ) {
         next if $field->inactive;
         my $result;
         my $field_name = $field->name;
         # Trim values and move to "input" slot
         $result = $field->_result_from_input( $input->{$field_name}, exists $input->{$field_name} );
         if( $result )
         {
            $result->parent($self_result);
            $self_result->add_result($result);
         }
      }
   }
   return $self_result;
}


# building fields from model object or init_obj hash
# formerly _init_from_object
sub _result_from_object
{
   my ( $self, $item ) = @_;

   return unless $item;
   $self->clear_result if $self->has_result;
   my $self_result = $self->result;
   my $my_value;
   for my $field ( $self->fields ) {
      next if $field->parent && $field->parent != $self;
      next if ref $item eq 'HASH' && !exists $item->{ $field->accessor };
      my $value = $self->_get_value( $field, $item );
      my $result = $field->_result_from_object( $value );
      $self_result->add_result($result) if $result;
      $my_value->{ $field->name } = $field->value;
   }
   $self_result->_set_value($my_value);
   return $self_result;
}

sub _get_value
{
   my ( $self, $field, $item ) = @_;
   my $accessor = $field->accessor;
   my @values;
   if ( blessed($item) && $item->can($accessor) ) {
      @values = $item->$accessor;
   }
   elsif ( exists $item->{$accessor} ) {
      @values = $item->{$accessor};
   }
   else {
      return;
   }
   my $value = @values > 1 ? \@values : shift @values;
   return $value;
}

=head1 AUTHORS

HTML::FormHandler Contributors; see HTML::FormHandler

Initially based on the original source code of L<Form::Processor::Field> by Bill Moseley

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose::Role;
1;
