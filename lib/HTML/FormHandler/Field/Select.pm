package HTML::FormHandler::Field::Select;

use Moose;
extends 'HTML::FormHandler::Field';
our $VERSION = '0.01';

=head1 NAME

HTML::FormHandler::Field::Select

=head1 DESCRIPTION

This is a field that includes a list of possible valid options.
This can be used for select and mulitple-select fields.
Widget type is 'select'.

=head1 METHODS

=head2 options

This is an array of hashes for this field.
Each has must have a label and value keys.

=cut

has 'options' => ( isa => 'ArrayRef[HashRef]', is => 'rw',
                   metaclass => 'Collection::Array',
                   auto_deref => 1,
                   provides => {
                      clear => 'reset_options',
                   },
                   lazy => 1, 
                   builder => 'build_options' );
sub build_options { [] };

=head2 set_options

Name of form method that sets options

=cut

has 'set_options' => ( isa => 'Str', is => 'rw',
       default => sub {
       my $self = shift;
       my $name = $self->full_name;
       $name =~ s/\./_/g;
       return 'options' . $name;
    }
);
sub _can_options
{
   my $self = shift;
   return unless $self->form && 
                 $self->set_options && 
                 $self->form->can( $self->set_options);
   return 1;
}
sub _options
{
   my $self = shift;
   return unless $self->_can_options;
   my $meth = $self->set_options;
   $self->form->$meth( $self );
}

=head2 multiple

If true allows multiple input values

=cut

has 'multiple' => ( isa => 'Bool', is => 'rw', default => '0' );

=head2 size

This can be used to store how many items should be offered in the UI
at a given time.  Defaults to 0.

=cut

has 'size'     => ( isa => 'Int|Undef', is => 'rw', default => '0' );

=head2 label_column

Sets or returns the name of the method to call on the foreign class
to fetch the text to use for the select list.

Refers to the method (or column) name to use in a related
object class for the label for select lists.

Defaults to "name"

=cut

has 'label_column' => ( isa => 'Str', is => 'rw', default => 'name' );

=head2 active_column

Sets or returns the name of a boolean column that is used as a flag to indicate that
a row is active or not.  Rows that are not active are ignored.

The default is "active".

If this column exists on the class then the list of options will included only
rows that are marked "active".

The exception is any columns that are marked inactive, but are also part of the
input data will be included with brackets around the label.  This allows
updating records that might have data that is now considered inactive.

=cut

has 'active_column' => ( isa => 'Str', is => 'rw', default => 'active' );

=head2 auto_widget_size

This is a way to provide a hint as to when to automatically
select the widget to display for fields with a small number of options.
For example, this can be used to decided to display a radio select for
select lists smaller than the size specified.

See L<select_widget> below.

=cut

has 'auto_widget_size' => ( isa => 'Int', is => 'rw', default => '0' );

=head2 sort_column

Sets or returns the column used in the foreign class for sorting the
options labels.  Default is undefined.

If this column exists in the foreign table then labels returned will be sorted
by this column.

If not defined or the column is not found as a method on the foreign class then
the label_column is used as the sort condition.

=cut

has 'sort_column' => ( isa => 'Str', is => 'rw' );

has '+widget' => ( default => 'select' );




=head2 select_widget

If the widget is 'select' for the field then will look if the field
also has a L<auto_widget_size>.  If the options list is less than or equal
to the L<auto_widget_size> then will return C<radio> if L<multiple> is false,
otherwise will return C<checkbox>.

=cut

sub select_widget {
    my $field = shift;

    my $size = $field->auto_widget_size;
    return $field->widget unless $field->widget eq 'select' && $size;
    my $options = $field->options || [];
    return 'select' if @$options > $size;
    return $field->multiple ? 'checkbox' : 'radio';
}

=head2 as_label

Returns the option label for the option value that matches the field's current value.
Can be helpful for displaying information about the field in a more friendly format.

This does a string compare, although probably al

=cut

sub as_label {
    my $field = shift;

    my $value = $field->value;
    return unless defined $value;

    for ( $field->options ) {
        return $_->{label} if $_->{value} eq $value;
    }

    return;
}

=head2 process 

Checks that this is a multiple field if the input is an array. 
The input value (or values if an array ref) is tested to make 
sure they all are valid options.

Returns true or false

=cut

augment 'process' => sub
{
   my ($self) = @_;

   # create a lookup hash
   my %options = map { $_->{value} => 1 } $self->options;

   my $input = $self->input;

   return 1 unless defined $input;    # nothing to check

   if ( ref $input eq 'ARRAY'
      && !( $self->can('multiple') && $self->multiple ) )
   {
      $self->add_error('This field does not take multiple values');
      return;
   }

   for my $value ( ref $input eq 'ARRAY' ? @$input : ($input) )
   {
      unless ( $options{$value} )
      {
         $self->add_error("'$value' is not a valid value");
         return;
      }
   }
   inner();
   return 1;
};


=head1 AUTHORS

Gerda Shank, gshank@cpan.org

Based on the original source code of L<Form::Processor::Field::Select> by Bill Moseley

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;
1;
