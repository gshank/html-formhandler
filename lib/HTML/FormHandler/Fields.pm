package HTML::FormHandler::Fields;

use Moose::Role;

=head1 NAME

HTML::FormHandler::Fields;

=head1 SYNOPSIS

A role to implement field attributes, accessors, etc. To be applied
to L<HTML::FormHandler> and L<HTML::FormHandler::Field::Compound>.

=head2 fields

The field definitions as built from the field_list and the 'has_field'
declarations. This is a MooseX::AttributeHelpers::Collection::Array,
and provides clear_fields, add_field, remove_last_field, num_fields,
has_fields, and set_field_at methods.

=head2 field( $full_name )

Return the field objct with the full_name passed. Will return undef
if the field is not found, or will die if passed a second parameter.

=head2 field_index

Convenience function for use with 'set_field_at'. Pass in 'name' of field
(not full_name)

=head2 sorted_fields

Calls fields and returns them in sorted order by their "order"
value. Non-sorted fields are retrieved with 'fields'.

=head2 clear methods

  clear_data
  clear_fields
  clear_error_fields

=head2 Dump information

   dump - turn verbose flag on to get this output
   dump_validated - shorter version

=cut

has 'fields' => (
   metaclass  => 'Collection::Array',
   isa        => 'ArrayRef[HTML::FormHandler::Field]',
   is         => 'rw',
   default    => sub { [] },
   auto_deref => 1,
   provides   => {
      clear => 'clear_fields',
      push  => 'push_field',
      pop   => 'remove_last_field',
      count => 'num_fields',
      empty => 'has_fields',
      set   => 'set_field_at',
   }
);

# compatibility wrappers for result errors
sub error_fields
{
   my $self = shift;
   return map { $_->field_def } @{$self->result->error_results};
}
sub has_error_fields { shift->result->has_error_results }
sub add_error_field 
{
   my ($self, $field) = @_;
   $self->result->add_error_result($field->result);
}
sub num_error_fields { shift->result->num_error_results }

sub add_field
{
   shift->push_field(@_);
}

has 'field_name_space' => (
   isa     => 'Str|ArrayRef[Str]|Undef',
   is      => 'rw',
   lazy    => 1,
   default => '',
);

sub field_index
{
   my ( $self, $name ) = @_;
   my $index = 0;
   for my $field ( $self->fields ) {
      return $index if $field->name eq $name;
      $index++;
   }
   return;
}

sub field
{
   my ( $self, $name, $die ) = @_;

   my $index;
   # if this is a full_name for a compound field
   # walk through the fields to get to it
   if ( $name =~ /\./ ) {
      my @names = split /\./, $name;
      my $f = $self->form || $self;
      foreach my $fname (@names) {
         $f = $f->field($fname);
         return unless $f;
      }
      return $f;
   }
   else    # not a compound name
   {
      for my $field ( $self->fields ) {
         return $field if ( $field->name eq $name );
      }
   }
   return unless $die;
   die "Field '$name' not found in '$self'";
}

# this may be an array of fields flattened from the tree
sub sorted_fields
{
   my $self = shift;

   my @fields = sort { $a->order <=> $b->order } grep { !$_->inactive } $self->fields;
   return wantarray ? @fields : \@fields;
}

#  the routine for looping through and processing each field
sub _fields_validate
{
   my $self = shift;
   return unless $self->has_fields;
   # validate all fields
   my %value_hash;
   foreach my $field ( $self->fields ) {
      next if ( $field->inactive  || !$field->has_result );
      # Validate each field and "inflate" input -> value.
      $field->validate_field;    # this calls the field's 'validate' routine
      $value_hash{ $field->accessor } = $field->value 
          if ( $field->has_value && !$field->noupdate );
   }
   $self->_set_value( \%value_hash );
}

sub fields_fif
{
   my ( $self, $prefix ) = @_;
$DB::single=1;
   $prefix ||= '';
   return unless $self->has_result;
   if ( $self->isa( 'HTML::FormHandler' ) ) { 
      $prefix = $self->name . "." if $self->html_prefix;
   }
   my %params;
   foreach my $field ( $self->fields ) {
      next if ( $field->inactive || $field->password );
      # result might be undef if garbage collected
      next unless $field->has_result && $field->result;
      my $fif = $field->fif;
      next unless defined $fif;
      if ( $field->has_fields ) {
         my $next_params = $field->fields_fif( $prefix . $field->name . '.' );
         next unless $next_params;
         %params = ( %params, %{$next_params} );
      }
      else {
         $params{ $prefix . $field->name } = $fif;
      }
   }
   return if !%params;
   return \%params;
}

sub clear_data 
{ 
   my $self = shift;
   $self->clear_result;
   $_->clear_data for $self->fields; 
}

sub get_error_fields
{
   my $self = shift;

   my @error_results;
   foreach my $field ( $self->sorted_fields ) {
      next unless $field->has_result;
      if ( $field->has_fields ) {
         $field->get_error_fields;
         push @error_results, @{$field->result->error_results} 
              if $field->result->has_error_results;
      }
      push @error_results, $field->result if $field->result->has_errors;
   }
   $self->result->add_error_result(@error_results) if scalar @error_results;
}

sub dump_fields { shift->dump(@_) }

sub dump
{
   my $self = shift;

   warn "HFH: ------- fields for ", $self->name, "-------\n";
   for my $field ( $self->sorted_fields ) {
      $field->dump;
   }
   warn "HFH: ------- end fields -------\n";
}

sub dump_validated
{
   my $self = shift;
   warn "HFH: fields validated:\n";
   foreach my $field ( $self->fields ) {
      $field->dump_validated if $field->can('dump_validated');
      warn "HFH: ", $field->name, ": ",
         ( $field->has_errors ? join( ' | ', $field->errors ) : 'validated' ), "\n";
   }
}

no Moose::Role;
1;
