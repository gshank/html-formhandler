package HTML::FormHandler::Field::Select;

use Moose;
extends 'HTML::FormHandler::Field';
use Carp;
our $VERSION = '0.02';

=head1 NAME

HTML::FormHandler::Field::Select

=head1 DESCRIPTION

This is a field that includes a list of possible valid options.
This can be used for select and mulitple-select fields.
Widget type is 'select'.

This field type can also be used for fields that use the
'radio_group' widget.

The 'options' array can come from four different places.
The options attribute itself, either declaratively or using a
'build_options' method in the field, from a method in the
form ('options_<fieldname>') or from the database.

In a field declaration:

   has_field 'opt_in' => ( type => 'Select', widget => 'radio_group',
      options => [{ value => 0, label => 'No'}, { value => 1, label => 'Yes'} ] );

In a custom field class:

   sub build_options {
       my $i = 0;
       my @days = ('Sunday', 'Monday', 'Tuesda', 'Wednesday',
           'Thursday', 'Friday', 'Saturday' ); 
       return [
           map {
               {   value => $i++, label => $_ }
           } @days
       ];
   }

In a form:

   sub options_opt_in {
      [ { value => 0, label => 'No' }, {value => 1, label => 'Yes'} ]
   }

From a database when the name of the accessor is a relation to the
table holding the information used to construct the select list.
The primary key is used as the value. The other columns used are:

    label_column  --  Used for the labels in the options
    active_column --  The name of the column to be used in the query
                      that allows the rows retrieved to be restricted 
    sort_column   --  The name of the column used to sort the options


=head1 METHODS

=head2 options

This is an array of hashes for this field.
Each has must have a label and value keys.

=cut

has 'options' => (
   isa        => 'ArrayRef[HashRef]',
   is         => 'rw',
   metaclass  => 'Collection::Array',
   auto_deref => 1,
   provides   => {
      clear => 'reset_options',
      empty => 'has_options',
   },
   lazy    => 1,
   builder => 'build_options'
);
sub build_options { [] }
has 'options_from' => ( isa => 'Str', is => 'rw', default => 'none' );

=head2 set_options

Name of form method that sets options

=cut

sub BUILD
{
   my $self = shift;

   $self->set_options;
   $self->options_from('build') if $self->options && $self->has_options;
}

has 'set_options' => (
   isa     => 'Str',
   is      => 'rw',
   default => sub {
      my $self = shift;
      my $name = $self->full_name;
      $name =~ s/\./_/g;
      return 'options_' . $name;
   }
);

sub _can_options
{
   my $self = shift;
   return
      unless $self->form &&
         $self->set_options &&
         $self->form->can( $self->set_options );
   return 1;
}

sub _options
{
   my $self = shift;
   return unless $self->_can_options;
   my $meth = $self->set_options;
   return $self->form->$meth($self);
}

=head2 multiple

If true allows multiple input values

=cut

has 'multiple' => ( isa => 'Bool', is => 'rw', default => '0' );

=head2 size

This can be used to store how many items should be offered in the UI
at a given time.  Defaults to 0.

=cut

has 'size' => ( isa => 'Int|Undef', is => 'rw' );

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

sub select_widget
{
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
This does a string compare.

=cut

sub as_label
{
   my $field = shift;

   my $value = $field->value;
   return unless defined $value;

   for ( $field->options )
   {
      return $_->{label} if $_->{value} eq $value;
   }
   return;
}

sub _inner_validate_field
{
   my ($self) = @_;

   # load options because this is params validation
   $self->_load_options;

   my $value = $self->value;
   return 1 unless defined $value;    # nothing to check

   if ( ref $value eq 'ARRAY' &&
      !( $self->can('multiple') && $self->multiple ) )
   {
      $self->add_error('This field does not take multiple values');
      return;
   }
   elsif ( ref $value ne 'ARRAY' && $self->multiple )
   {
      $value = [$value];
      $self->value($value);
   }

   # create a lookup hash
   my %options = map { $_->{value} => 1 } $self->options;
   for my $value ( ref $value eq 'ARRAY' ? @$value : ($value) )
   {
      unless ( $options{$value} )
      {
         $self->add_error("'$value' is not a valid value");
         return;
      }
   }
   return 1;
}

sub _init
{
   my $self = shift;

   $self->SUPER::_init;
   # load options when no input and no value (empty form )
   $self->_load_options;
}

sub _load_options
{
   my $self = shift;

   return if $self->options_from eq 'build';
   my @options;
   if ( $self->_can_options )
   {
      @options = $self->_options;
      $self->options_from('method');
   }
   elsif ( $self->form )
   {
      my $full_accessor;
      $full_accessor = $self->parent->full_accessor if $self->parent;
      @options = $self->form->lookup_options( $self, $full_accessor );
      $self->options_from('model') if scalar @options;
   }
   return unless @options;    # so if there isn't an options method and no options
                              # from a table, already set options attributes stays put

   @options = @{ $options[0] } if ref $options[0];
   croak "Options array must contain an even number of elements for field " . $self->name
      if @options % 2;

   my @opts;
   push @opts, { value => shift @options, label => shift @options } while @options;
   $self->options( \@opts ) if @opts;
}

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
