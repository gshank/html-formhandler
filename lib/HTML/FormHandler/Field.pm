package HTML::FormHandler::Field;

use Moose;
use MooseX::AttributeHelpers;
use HTML::FormHandler::I18N;    # only needed if running without a form object.

our $VERSION = '0.02';

=head1 NAME

HTML::FormHandler::Field - Base class for HTML::FormHandler Fields

=head1 SYNOPSIS

Instances of Field subclasses are generally built by L<HTML::FormHandler>
from the field_list, but they can also be constructed using new.

    use HTML::FormHandler::Field::Text;
    my $field = HTML::FormHandler::Field::Text->new( name => $name, ... );

In your custom field class:

    package MyApp::Field::MyText;
    extends 'HTML::FormHandler::Field::Text';

    has 'my_attribute' => ( isa => 'Str', is => 'rw' );
    sub validate { ... }
    1;

=head1 DESCRIPTION

This is the base class for form fields. The 'type' of a field class
is used in the FormHandler field_list or has_field to identify which field class to
load.  

A number of field classes are provided by the distribution. The basic
field types are:

   Text
   Integer
   Select
   Boolean

These field types alone would be enough for most applications, since
the equivalent of the others could be defined using field attributes
and custom validation methods.  There is some benefit to having
descriptive names, of course, and if you have multiple fields  
requiring the same validation, you should certainly define a custom
field class.

Inheritance hierarchy of the distribution's field classes:

   Text
      Money
      Password
      Integer
         PosInteger
   TextArea
      HtmlArea
   Select
      Multiple
      IntRange
         Hour
         Minute
         MonthDay
         Month
         Second
         Year
      MonthName 
      Weekday
         WeekdayStr
   Boolean
      Checkbox
   DateMDY
   DateTime
   Email
      
See the documentation or source for the individual fields.

Normally you would implement a 'validate' routine in a custom
field class, but you can also override the base validation routine
by overriding 'validate_field'.

=head1 ATTRIBUTES

=head2 name

Field name. If this is a database form, this name is usually a database 
column/accessor name or relationship.

=cut

has 'name' => ( isa => 'Str', is => 'rw', required => 1 );

=head2 type

Field type (e.g. 'Text', 'Select' ... ) from a HTML::FormHandler::Field
subclass, either one provided in the distribution or one that you
create yourself, proceded by a "+":  type => '+MetaText'

=cut

has 'type' => ( isa => 'Str', is => 'rw', default => sub { ref shift } );

=head2 init_value

Initial value populated by init_from_object. You can tell if a field
has changed by comparing 'init_value' and 'value'.
Not to be confused with the form method init_value(). Not set by user.

=cut

has 'init_value' => ( is => 'rw' );

=head2 value

The initial value of the field from the database (or init_object), and 
the changed value after form validation. A change in this attribute 
triggers setting the 'fif' attribute.

The "validate" field method usually sets this value if the field validates.

The user does not need to set this field except in validation methods.

=cut

has 'value' => (
   is      => 'rw',
   clearer => 'clear_value',
   predicate => 'has_value',
   trigger => sub {
      my ( $self, $value ) = @_;
      $self->fif($self->fif_value($value)) 
            unless ($self->password && $self->password == 1);
      return $value;
   }
);

=head2 input

Input value for the field, moved from the parameter hash.
In L<HTML::FormHandler>, the setter for this attribute is for internal 
use. If you want to set an input value, use the 'set_param' method. 
A field validation routine may copy the value of this attribute to 
the 'value' attribute. The setter may be used in field tests and
if a field class is used standalone. A change in this attribute triggers 
setting 'fif'. 

=cut

has 'input' => (
   is      => 'rw',
   clearer => 'clear_input',
   predicate => 'input_exists',
   trigger => sub {
      my ( $self, $input ) = @_;
      $self->fif($input)
            unless ($self->password && $self->password == 1);
      return $input;
   }
);

=head2 fif

For filling in forms. Input or value. The user does not need to set this field.
It is set by FormHandler from the values in your database object or the
input parameters. The normal use would be to a access this field from a template:

   [% f = form.field('title') %]
   [% f.fif %]

=cut

has 'fif' => ( is => 'rw' ); 

=head2 temp

Temporary attribute. Not used by HTML::FormHandler.

=cut

has 'temp' => ( is => 'rw' );

=head2 label

Text label for this field. Useful in templates. Defaults to ucfirst field name.

=cut

has 'label' => (
   isa     => 'Str',
   is      => 'rw',
   lazy    => 1,
   default => sub { ucfirst(shift->name) }, 
);

=head2 title

Place to put title for field, for mouseovers. Not used by F::P.

=cut

has 'title' => ( isa => 'Str', is => 'rw' );

=head2 style

Field's generic style to use for css formatting in templates.
Not actually used by F::P. 

=cut

has 'style' => ( isa => 'Str', is => 'rw' );

=head2 css_class

Field's css_class for use in templates.

=cut

has 'css_class' => ( isa => 'Str', is => 'rw' );

=head2 sub_form

The field is made up of a sub-form.

A single field can be represented by multiple sub-fields
contained in a form.  This is a reference to that form.

=cut

has 'sub_form' => ( isa => 'Str', is => 'rw' );

=head2 form

A reference to the containing form.

=cut

has 'form' => ( is => 'rw', weak_ref => 1 );

=head2 prename

Field name prefixed by the form name and a dot.
A field named "street" in a form named "address" would
have a prename of "address.street". Use with the
form attribute "html_prefix". Allows multiple forms with
the same field names.

=cut

has 'prename' => (
   isa     => 'Str',
   is      => 'rw',
   lazy    => 1,
   builder => 'build_prename'
);

sub build_prename
{
   my $self = shift;
   my $prefix = $self->form ? $self->form->name . "." : '';
   return $prefix . $self->name;
}

=head2 widget

The 'widget' is attribute is not used by base FormHandler code.
It is intended for use in generating HTML, in templates and the 
rendering roles. Fields of different type can use the same 
widget.

This attribute is set in the field classes, or in the fields
defined in the form.

Widget types for the provided field classes:

    Widget      : Field classes 
    ------------:-----------------------------------
    text        : Text, Integer
    checkbox    : Checkbox, Select
    radio       : Boolean, Select
    select      : Select, Multiple
    textarea    : TextArea, HtmlArea
    compound    : DateTime
    password    : Password

The 'Select' field class has a 'select_widget' method that chooses
which widget to use, which could be called by templates or rendering
roles.

The default widget is 'text'.

=cut

has 'widget' => ( isa => 'Str', is => 'rw', default => 'text' );

=head2 order

This is the field's order used for sorting errors and field lists.
See the "set_order" method and F::P method "sorted_fields".
The order field is set for the fields when the form is built, but
if the fields are defined with a hashref the order will not be defined.
The "auto" and "fields" field_list attributes will take an arrayref which
will preserve the order. If you explicitly set "order" on the fields
in a field_list, you should set it on all the fields, otherwise results
will be unpredictable.

=cut

has 'order' => ( isa => 'Int', is => 'rw', default => 0 );

=head2 required

Flag indicating whether this field must have a value

=cut

has 'required' => ( isa => 'Bool', is => 'rw', default => '0' );

=head2 required_message

Error message text added to errors if required field is not present

The default is "Field <field label> is required".

=cut

has 'required_message' => ( isa => 'Str', is => 'rw', lazy => 1, 
     default => sub { shift->label . ' field is required' } );

=head2 unique

Flag to initiate checks in the database model for uniqueness.

=cut

has 'unique' => ( isa => 'Bool', is => 'rw' );

=head2 unique_message

Error message text added to errors if field is not unique

=cut

has 'unique_message' => ( isa => 'Str', is => 'rw' );

=head2 range_start

=head2 range_end

Field values are validated against the specified range if one
or both of range_start and range_end are set and the field
does not have 'options'.

The IntRange field uses this range to create a select list 
with a range of integers.

In a FormHandler field_list

    age => {
        type            => 'Integer',
        range_start     => 18,
        range_end       => 120,
    }

Or just set one:

    age => {
        type            => 'Integer',
        range_start     => 18,
    }

Range checks are done after validation so
must only be used on appropriate fields

=cut

has 'range_start' => ( isa => 'Int|Undef', is => 'rw', default => undef );
has 'range_end'   => ( isa => 'Int|Undef', is => 'rw', default => undef );

=head2 value_sprintf

This is a sprintf format string that is used when moving the field's
input data to the field's value attribute.  By defult this is undefined,
but can be set in fields to alter the way the input_to_value() method
formates input data.

For example in a field that represents money the field could define:

    has '+value_sprintf' => ( default => '%.2f' );

The field's 'value' will be formatted with two decimal places.

=cut

has 'value_sprintf' => ( isa => 'Str|Undef', is => 'rw' );

=head2 id, build_id

Provides an 'id' for the field. Useful for javascript.
The default id is:

    $field->form->name . $field->id

Override with "build_id".

=cut

has 'id' => ( isa => 'Str', is => 'rw', lazy => 1, builder => 'build_id' );

sub build_id
{
   my $field = shift;
   my $form_name = $field->form ? $field->form->name : 'fld-';
   return $form_name . $field->name;
}

=head2 javascript

Store javascript for the field

=cut

has 'javascript' => ( isa => 'Str', is => 'rw' );

=head2 password

This is a boolean flag to prevent the field from being returned in
the C<$form->fif> and C<$field->fif> methods. 

=cut

has 'password' => ( isa => 'Bool', is => 'rw' );

=head2 writeonly

Fields flagged 'writeonly' are not returned in the 'fif' methods from the
field's initial value, even if a value for the field exists in the item.
The value is not read from the database.
However, the value entered into the form WILL be returned. This might
be used for columns that should only be written to the database on updates.

=cut

has 'writeonly' => ( isa => 'Bool', is => 'rw' );

=head2 clear

This is a flag that says you want to set the database column to null for this
field.  Validation is also not run on this field.

=cut

has 'clear' => ( isa => 'Bool', is => 'rw' );

=head2 disabled

=head2 readonly

These allow you to enter hints about how the html element is generated.  

HTML::FormHandler does not use these attributes; they are for your convenience
in constructing HTML. 

=cut

has 'disabled' => ( isa => 'Bool', is => 'rw' );
has 'readonly' => ( isa => 'Bool', is => 'rw' );

=head2 noupdate

This boolean flag indicates a field that should not be updated.  Fields
flagged as noupdate are skipped when processed by the model.

This is useful when a form contains extra fields that are not directly
written to the data store.

=cut

has 'noupdate' => ( isa => 'Bool', is => 'rw' );

=head2 errors

Returns the error list for the field. Also provides 'num_errors',
'has_errors', 'push_errors' and 'clear_errors' from Collection::Array 
metaclass. Use 'add_error' to add an error to the array if you
want to use a MakeText language handle. Default is an empty list. 

=cut

has 'errors' => (
   metaclass  => 'Collection::Array',
   isa        => 'ArrayRef[Str]',
   is         => 'rw',
   auto_deref => 1,
   default    => sub {[]},
   provides   => { 
      'push'  => 'push_errors', 
      'count' => 'num_errors',
      'empty' => 'has_errors',
      'clear' => 'clear_errors',
   }
);


=head2 validate_meth

Specify the form method to be used to validate this field.
The default is C<< 'validate_' . $field->name >>. (Periods in
field names will be changed to underscores.) If you have
a number of fields that require the same validation and don't
want to write a field class, you could set them all to the same 
method name.

   has_field 'title' => ( isa => 'Str', validate_meth => 'check_title' );
   has_field 'subtitle' => ( isa => 'Str', validate_meth => 'check_title' );

=cut

has 'validate_meth' => ( isa => 'Str', is => 'rw', lazy => 1,
    default => sub { 
       my $self = shift; 
       my $name = $self->name;
       $name =~ s/\./_/g;
       return 'validate_' . $name;
    }
);


# tell Moose to make this class immutable
__PACKAGE__->meta->make_immutable;

=head1 METHODS

=head2 new [parameters]

Create a new instance of a field.  Initial values are passed 
as a list of parameters.

=head2 full_name

This returns the name of the field, but if the field
is a child field will prepend the field with the parent's field
name.  For example, if a field is "month" and the parent's field name
is "birthday" then this will return "birthday.month".

=cut

sub full_name
{
   my $field = shift;

   my $name   = $field->name;
   my $form   = $field->form || return $name;
   my $parent = $form->parent_field || return $name;
   return $parent->name . '.' . $name;
}

=head2 set_order

This sets the field's order to the form's field_counter
and increments the counter. This may be used in a template
when displaying the field.

=cut

sub set_order
{
   my $field = shift;
   my $form  = $field->form;
   my $order = $form->field_counter || 1;
   $field->order($order);
   $form->field_counter( $order + 1 );
}

=head2 add_error

Add an error to the list of errors.  If $field->form
is defined then process error message as Maketext input.
See $form->language_handle for details. Returns undef.  

    return $field->add_error( 'bad data' ) if $bad;

=cut

sub add_error
{
   my $self = shift;

   my $form = $self->form;
   my $lh;
   # By default errors get attached to the field where they happen.
   my $error_field = $self;
   # Running without a form object?
   if ($form)
   {
      $lh = $form->language_handle;

      # If we are a sub-form then redirect errors to the parent field
      $error_field = $form->parent_field if $form->parent_field;
   }
   else
   {
      $lh = $ENV{LANGUAGE_HANDLE}
         || HTML::FormHandler::I18N->get_handle
         || die "Failed call to Locale::Maketext->get_handle";
   }
   $self->push_errors( $lh->maketext(@_) );
   return;
}


=head2 validate_field

This method does standard validation, which currently tests:

    required        -- if field is required and value exists

Then if a value exists:

    test_multiple   -- looks for multiple params passed in when not allowed
    test_options    -- tests if the params passed in are valid options

If these tests pass, the field's validate method is called

    $field->validate;

If C<< $field->validate >> returns true then the input value
is copied from the input attribute to the field's value attribute
by calling:

    $field->input_to_value;

The default method simply copies the value.  This method is only called
if the field does not have any errors.

The field's error list and internal value are reset upon entry.

=cut

# TODO: move test_multiple and test_options to the field classes?
#
sub validate_field
{
   my $field = shift;

   $field->clear_errors;
   # See if anything was submitted
   unless ( $field->has_input )
   {
      $field->add_error( $field->required_message) if( $field->required );
      $field->clear_value if( $field->input_exists);
      return;
   }

   $field->clear_value;
   return unless $field->test_multiple;
   return unless $field->test_options;
   return unless $field->validate;
   return unless $field->test_ranges;

   # Now move data from input -> value
   $field->input_to_value;
   return;
}

=head2 validate

This method validates the input data for the field and returns true if
the data validates.  An error message must be added to the field with
C<< $field->add_error( ... ) >> if the value does not validate. The default 
method is to return true.

    sub validate {
        my $field = shift;
        my $input = $field->input;
        return $field->add_error( ... ) if ( ... );
        return 1;
    }

=cut

sub validate { 1 }


=head2 input_to_value

This method moves the 'input' attribute value to the 'value' attribute
if 'value' is undefined (has not already been set in 'validate').
It calls the 'value_sprintf' routine to format the value before moving it.

Override this method if you want to convert the input to another format
before saving in 'value'.

=cut

sub input_to_value
{
   my $field = shift;

   return if defined $field->value;    # already set by validate method.
   my $format = $field->value_sprintf;
   if ($format)
   {
      $field->value( sprintf( $format, $field->input ) );
   }
   else
   {
      $field->value( $field->input );
   }
}

=head2 test_ranges

If range_start and/or range_end is set AND the field
does not have options will test that the value is within
range.  This is called after all other validation.

=cut

sub test_ranges
{
   my $field = shift;
   return 1 if $field->can('options') || $field->has_errors;

   my $input = $field->input;

   return 1 unless defined $input;

   my $low  = $field->range_start;
   my $high = $field->range_end;

   if ( defined $low && defined $high )
   {
      return $input >= $low && $input <= $high
         ? 1
         : $field->add_error( 'value must be between [_1] and [_2]', $low, $high );
   }

   if ( defined $low )
   {
      return $input >= $low
         ? 1
         : $field->add_error( 'value must be greater than or equal to [_1]', $low );
   }

   if ( defined $high )
   {
      return $input <= $high
         ? 1
         : $field->add_error( 'value must be less than or equal to [_1]', $high );
   }

   return 1;
}

=head2 trim_value

Trims leading and trailing white space for single parameters.
If the parameter is an array ref then each value is trimmed.

Pass in the value to trim and returns value back

=cut

sub trim_value
{
   my ( $self, $value ) = @_;

   return unless defined $value;

   my @values = ref $value eq 'ARRAY' ? @$value : ($value);
   for (@values)
   {
      next if ref $_;
      s/^\s+//;
      s/\s+$//;
   }
   return @values > 1 ? \@values : $values[0];
}

=head2 test_multiple

Returns false if the field is a multiple field
and the input for the field is a list.


=cut

sub test_multiple
{
   my ($self) = @_;

   my $value = $self->input;
   if ( ref $value eq 'ARRAY'
      && !( $self->can('multiple') && $self->multiple ) )
   {
      $self->add_error('This field does not take multiple values');
      return;
   }
   return 1;
}

=head2 has_input

Returns true if $self->input contains any non-blank input.

=cut

sub has_input
{
   my ($self) = @_;
   return unless $self->input_exists;
   my $value = $self->input;
   # check for one value as defined
   return grep { /\S/ } @$value
      if ref $value eq 'ARRAY';
   return defined $value && $value =~ /\S/;
}

=head2 test_options

If the field has an "options" method then the input value (or values
if an array ref) is tested to make sure they all are valid options.

Returns true or false

=cut

sub test_options
{
   my ($self) = @_;

   return 1 unless $self->can('options');

   # create a lookup hash
   my %options = map { $_->{value} => 1 } $self->options;

   my $input = $self->input;

   return 1 unless defined $input;    # nothing to check

   for my $value ( ref $input eq 'ARRAY' ? @$input : ($input) )
   {
      unless ( $options{$value} )
      {
         $self->add_error("'$value' is not a valid value");
         return;
      }
   }

   return 1;
}

=head2 fif_value

A field class can use this method to format an internal
value into hash for form parameters.

A Date field subclass might expand the value into:

    my $name = $field->name;
    return (
        $name . 'd'  => $day,
        $name . 'm' => $month,
        $name . 'y' => $year,
    );

=cut

sub fif_value
{
   my ($self, $value)  = @_;
   return $value;
}

=head2 value_changed

Returns true if the value in the item has changed from what is currently in the
field's value.

This only does a string compare (arrays are sorted and joined).

=cut

sub value_changed
{
   my ($self) = @_;

   my @cmp;
   for ( 'init_value', 'value' )
   {
      my $val = $self->$_;
      $val = '' unless defined $val;
      push @cmp, join '|', sort
         map { ref($_) && $_->isa('DateTime') ? $_->iso8601 : "$_" }
         ref($val) eq 'ARRAY' ? @$val : $val;
   }
   return $cmp[0] ne $cmp[1];
}

=head2 required_text

Returns "required" or "optional" based on the field's setting.

=cut

sub required_text { shift->required ? 'required' : 'optional' }

=head2 dump_field

A little debugging.

=cut

sub dump
{
   my $self = shift;

   require Data::Dumper;
   warn "HFH: -----  ",  $self->name, " -----\n";
   warn "HFH: type: ", $self->type, "\n";
   warn "HFH: required: ", ( $self->required || '0' ), "\n";
   warn "HFH: label: ", $self->label, "\n";
   warn "HFH: widget: ", $self->widget, "\n";
   my $v = $self->value;
   warn "HFH: value: ", Data::Dumper::Dumper $v if $v;
   my $iv = $self->init_value;
   warn "HFH: init_value: ", Data::Dumper::Dumper $iv if $iv;
   my $i = $self->input;
   warn "HFH: input: ", Data::Dumper::Dumper $i if $i;
   my $fif = $self->fif;
   warn "HFH: fif: ", Data::Dumper::Dumper $fif if $fif;

   if ( $self->can('options') )
   {
      my $o = $self->options;
      warn "HFH: options: " . Data::Dumper::Dumper $o;
   }
}

=head1 AUTHORS

Gerda Shank, gshank@cpan.org

Based on the original source code of L<Form::Processor::Field> by Bill Moseley

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose;
1;
