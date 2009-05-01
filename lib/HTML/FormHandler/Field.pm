package HTML::FormHandler::Field;

use HTML::FormHandler::Moose;
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
field class, but you can also override the base validation process
by overriding 'process'.

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
   is        => 'rw',
   clearer   => 'clear_value',
   predicate => 'has_value',
   trigger   => sub {
      my ( $self, $value ) = @_;
      $self->fif( $self->fif_value($value) )
         unless ( ( $self->password && $self->password == 1 )
         || $self->has_fields );
      return $value;
   }
);

=head2 parent

A reference to the parent of this field.

=cut

has 'parent' => ( is => 'rw', predicate => 'has_parent' );

=head2 errors_on_parent

Flag indicating that errors should not be set on this field class

=cut

has 'errors_on_parent' => ( isa => 'Bool', is => 'rw' );

sub has_fields { }

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
   is        => 'rw',
   clearer   => 'clear_input',
   predicate => 'has_input',
   trigger   => sub {
      my ( $self, $input ) = @_;
      $self->fif($input)
         unless ( $self->password && $self->password == 1 );
      return $input;
   }
);

=head2 input_without_param

Input for this field if there is no param. Needed for checkbox,
since an unchecked checkbox does not return a parameter.

=cut

has 'input_without_param' => (
   is        => 'rw',
   predicate => 'has_input_without_param'
);

=head2 fif

For filling in forms. Input or value. The user does not need to set this field.
It is set by FormHandler from the values in your database object or the
input parameters. The normal use would be to access this field from a template:

   [% f = form.field('title') %]
   [% f.fif %]

=cut

has 'fif' => ( is => 'rw', clearer => 'clear_fif', predicate => 'has_fif' );

=head2 accessor

If the name of your field is different than your database accessor, use
this attribute to provide the name of accessor.

=cut

has 'accessor' => (
   isa     => 'Str',
   is      => 'rw',
   lazy    => 1,
   default => sub {
      my $self     = shift;
      my $accessor = $self->name;
      $accessor =~ s/^(.*)\.//g if ( $accessor =~ /\./ );
      return $accessor;
   }
);

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
   default => sub { ucfirst( shift->name ) },
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

# should we remove/deprecate this?
has 'sub_form' => ( isa => 'HTML::FormHandler', is => 'rw' );

=head2 form

A reference to the containing form.

=cut

has 'form' => ( isa => 'HTML::FormHandler', is => 'rw', weak_ref => 1 );

=head2 html_name

Field name for use in HTML. If 'html_prefix' in the form has been set
the name will prefixed by the form name and a dot, otherwise this
attribute is the equivalient of 'full_name'.
A field named "street" in a form named "address" would
have a html_name of "address.street". Allows multiple forms with
the same field names.

=cut

has 'html_name' => (
   isa     => 'Str',
   is      => 'rw',
   lazy    => 1,
   builder => 'build_html_name'
);

# following is to maintain compatibility. remove eventually
sub prename { shift->html_name }

sub build_html_name
{
   my $self = shift;
   my $prefix = ($self->form && $self->form->html_prefix) ? 
                                 $self->form->name . "." : '';
   return $prefix . $self->full_name;
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

has 'required_message' => (
   isa     => 'Str',
   is      => 'rw',
   lazy    => 1,
   default => sub { shift->label . ' field is required' }
);

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

sub value_sprintf
{
   die "The 'value_sprintf' attribute has been removed. Please use a transformation instead.";
}

sub input_to_value
{
   die "The 'input_to_value' method has been removed. Use a transformation or move to the 'validate' method.";
}

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
   default    => sub { [] },
   provides   => {
      'push'  => 'push_errors',
      'count' => 'num_errors',
      'empty' => 'has_errors',
      'clear' => 'clear_errors',
   }
);

=head2 set_validate

Specify the form method to be used to validate this field.
The default is C<< 'validate_' . $field->name >>. (Periods in
field names will be changed to underscores.) If you have
a number of fields that require the same validation and don't
want to write a field class, you could set them all to the same 
method name.

   has_field 'title' => ( isa => 'Str', set_validate => 'check_title' );
   has_field 'subtitle' => ( isa => 'Str', set_validate => 'check_title' );

=cut

has 'set_validate' => (
   isa     => 'Str',
   is      => 'rw',
   lazy    => 1,
   default => sub {
      my $self = shift;
      my $name = $self->full_name;
      $name =~ s/\./_/g;
      return 'validate_' . $name;
   }
);

sub _can_validate
{
   my $self = shift;
   return
      unless $self->form
         && $self->set_validate
         && $self->form->can( $self->set_validate );
   return 1;
}

sub _validate
{
   my $self = shift;
   return unless $self->_can_validate;
   my $meth = $self->set_validate;
   $self->form->$meth($self);
}

=head2 set_init

The name of the method in the form that provides a field's initial value

=cut

has 'set_init' => (
   isa     => 'Str',
   is      => 'rw',
   lazy    => 1,
   default => sub {
      my $self = shift;
      my $name = $self->full_name;
      $name =~ s/\./_/g;
      return 'init_value_' . $name;
   }
);

sub _can_init
{
   my $self = shift;
   return
      unless $self->form
         && $self->set_init
         && $self->form->can( $self->set_init );
   return 1;
}

sub _init
{
   my $self = shift;
   return unless $self->_can_init;
   my $meth = $self->set_init;
   $self->form->$meth($self);
}

=head2 apply

Use the 'apply' keyword to specify an ArrayRef of constraints and coercions to 
be executed on the field at process time.  

   has_field 'test' => ( 
      apply => [ 'MooseType', { check => sub {...}, message => { } } 
   );

In general the action can be of three types: a Moose type (which is 
represented by it's name), a transformation (which is a callback called on 
the value of the field), or a constraint ('check') which performs a 'smart match' 
on the value of the field.  Currently we implement the smart match
in our code - but in the future when Perl 5.10 is more widely used we'll switch 
to the core
L<http://search.cpan.org/~rgarcia/perl-5.10.0/pod/perlsyn.pod#Smart_matching_in_detail>
smart match operator.  

The Moose type action first tries to coerce the value - 
then it checks the result, so you can use it instead of both constraints and 
tranformations - TIMTOWTDI.  For most constraints and transformations it is 
your choice as to whether you use a Moose type or use a 'check' or 'transform'. 

All three types define a message to be presented to the user in the case of 
failure. Transformations and coercions are called in an eval 
to catch the errors. Warnings are also trapped.

All the actions are called in the order that they are defined, so that you can 
check constraints after transformations and vice versa. You can weave all three 
types of actions in any order you need. The actions specified with 'apply' will
be stored in an 'actions' array. 

To declare actions inside a field class use L<HTML::FormHandler::Moose> and
'apply' sugar:

   package MyApp::Field::Test;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler::Field;

   apply [ 'SomeConstraint', { check => ..., message => .... } ];

   1;
   
Actions specified with apply are cumulative. Actions may be specified in
field classes and additional actions added in the 'has_field' declaration.

=head2 Moose types for constraints and transformations

Moose types can be used to do both constraints and transformations. If a coercion
exists it will be applied, resulting in a transformation.

A Moose type:
  subtype 'MyStr'
      => as 'Str'
      => where { /^a/ };

This is a simple constraint checking if the value string starts with the letter 'a'.

Another Moose type:
  subtype 'MyInt'
      => as 'Int';
  coerce 'MyInt'
      => from 'MyStr'
      => via { return $1 if /(\d+)/ };

This type contains a coercion.

You can use them in a field like this:

   has_field 'some_text_to_int' => (
       apply => [ 'MyStr', 'MyInt' ]
   );

This will check if the field contains a string starting with 'a' - and then coerce it
to an integer by extracting the first continues string of digits.

If the error message returned by the Moose type is not suitable for displaying
in a form, you can define a different error message:

   apply => [ { type => 'MyStr', message => 'Not a valid value' } ];

=head2 Non-Moose checks and transforms

A simple 'check' constraint uses the 'check' keyword pointing to a coderef,
a regular expression, or an array of valid values, plus a message.

A 'check' coderef will be passed the current value of the field. It should
return true or false:

  has_field 'this_num' => (
      apply => [
         {
             check => sub { if ( $_[0] =~ /(\d+)/ ) { return $1 > 10 } },
             message => 'Must contain number greater than 10',
         }
  );

A 'check' regular expression:

  has_field 'some_text' => (
      apply => [ { check => qr/aaa/, message => 'Must contain aaa' } ],
  );

A 'check' array of valid values:

  has_field 'more_text' => (
      aply => [ { check => ['aaa', 'bbb'], message => 'Must be aaa or bbb' } ]
  );

A simple transformation uses the 'transform' keyword and a coderef.
The coderef will be passed the current value of the field and should return
a transformed value.

  has_field 'sprintf_filter' => (
      apply => [ { transform => sub{ sprintf '<%.1g>', $_[0] } } ]
  );


=cut

has 'actions' => (
   metaclass  => 'Collection::Array',
   isa        => 'ArrayRef',
   is         => 'rw',
   auto_deref => 1,
   default    => sub { [] },
   provides   => {
      'push'  => 'add_action',
      'count' => 'num_actions',
      'empty' => 'has_actions',
      'clear' => 'clear_actions',
   }
);

=head2 deflations

Use deflations to convert from an inflated database or internal value to
a value suitable for displaying in an HTML form.

=cut

has 'deflations' => (
   metaclass  => 'Collection::Array',
   isa        => 'ArrayRef',
   is         => 'rw',
   auto_deref => 1,
   default    => sub { [] },
   provides   => {
      'push'  => 'add_deflation',
      'count' => 'num_deflations',
      'empty' => 'has_deflations',
      'clear' => 'clear_deflations',
   }
);

=head2 trim

A Hashref containing a transfrom to trim the field. By default
this contains a transform to strip beginning and trailing spaces.
Set this attribute to null to skip trimming, or supply a different
transform.

  trim => { transform => sub { } }

Trimming is performed before any other defined actions.

=cut

has 'trim' => ( isa => 'HashRef', is => 'rw', 
   default => sub {{ transform => 
      sub {
         my $value = shift;
         return unless defined $value;
         my @values = ref $value eq 'ARRAY' ? @$value : ($value);
         for (@values)
         {
            next if ref $_;
            s/^\s+//;
            s/\s+$//;
         }
         return ref $value eq 'ARRAY' ? \@values : $values[0];
      }
   }}
);


=head1 METHODS

=head2 new [parameters]

Create a new instance of a field.  Initial values are passed 
as a list of parameters.

=cut

sub BUILD
{
   my ( $self, $params ) = @_;

   $self->add_action($self->trim) if $self->trim;
   $self->_build_apply_list;
   $self->add_action( @{$params->{apply}} ) if $params->{apply};
}

sub _build_apply_list
{
   my $self = shift;
   my @apply_list;
   foreach my $sc ( reverse $self->meta->linearized_isa )
   {
      my $meta = $sc->meta;
      if ( $meta->can('calculate_all_roles') )
      {
         foreach my $role ( $meta->calculate_all_roles )
         {
            if ( $role->can('apply_list') && $role->has_apply_list )
            {
               push @apply_list, @{ $role->apply_list };
            }
         }
      }
      if ( $meta->can('apply_list') && $meta->has_apply_list )
      {
         push @apply_list, @{ $meta->apply_list };
      }
   }
   $self->add_action( @apply_list );
}

=head2 full_name

This returns the name of the field, but if the field
is a child field will prepend the field with the parent's field
name.  For example, if a field is "month" and the parent's field name
is "birthday" then this will return "birthday.month".

=cut

sub full_name
{
   my $field = shift;

   my $name = $field->name;
   my $parent = $field->parent || return $name;
   return $parent->full_name . '.' . $name;
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
   my ($self, @message) = @_;

   my $lh;
   unless( defined $message[0] )
   {
      @message = ('field is invalid');
   }
   # Running without a form object?
   if ( $self->form )
   {
      $lh = $self->form->language_handle;
   }
   else
   {
      $lh = $ENV{LANGUAGE_HANDLE}
         || HTML::FormHandler::I18N->get_handle
         || die "Failed call to Locale::Maketext->get_handle";
   }
   my $message = $lh->maketext(@message);
   $self->push_errors( $message ) unless $self->errors_on_parent;
   $self->parent->push_errors( $message ) if $self->parent;
   return;
}

=head2 process

This method does standard validation, which currently tests:

    required        -- if field is required and value exists

Then if a value exists, calls the 'augment' validate_field method in subclasses.

If these tests pass, the field's validate method is called

    $field->validate;

If C<< $field->validate >> returns true then the input value
is copied from the input attribute to the field's value attribute.

The field's error list and internal value are reset upon entry.

=cut

sub process
{
   my $field = shift;

   $field->clear_errors;
   # See if anything was submitted
   unless ( $field->input_defined )
   {
      $field->add_error( $field->required_message ) if ( $field->required );
      $field->value(undef)                          if ( $field->has_input );
      return;
   }

   $field->clear_value;

   $field->value( $field->input );

   # allow augment 'process' calls here
   inner();

   $field->_apply_actions;

   $field->_build_fif if $field->can('_build_fif');
   return if $field->has_errors;
   return unless $field->validate;
   return unless $field->test_ranges;

   return;
}

sub validate_field
{
   return shift->process(@_);
}

sub _apply_actions
{
   my $self  = shift;

   my $error_message;
   local $SIG{__WARN__} = sub {
      my $error = shift;
      $error_message = $error;
      return 1;
   };
   for my $action ( @{ $self->actions || [] } )
   {
      $error_message = undef;
      my $input = $self->value;
      # Moose constraints 
      if ( !ref $action )
      {
         $action = { type => $action };
      }
      if ( exists $action->{type} )
      {
         my $type = $action->{type};
         my $tobj = Moose::Util::TypeConstraints::find_type_constraint($type)
            or die 'Cannot find type constraint';
         my $new_value = $input;
         if ( $tobj->has_coercion && $tobj->validate($new_value) )
         {
            eval { $new_value = $tobj->coerce($new_value) };
            if ($@)
            {
               if ( $tobj->has_message )
               {
                  $error_message = $tobj->message->($new_value);
               }
               else
               {
                  $error_message = $@;
               }
            }
         }
         $error_message ||= $tobj->validate($new_value);
         if ( !$error_message )
         {
            $self->value($new_value);
         }
      }
      # now maybe: http://search.cpan.org/~rgarcia/perl-5.10.0/pod/perlsyn.pod#Smart_matching_in_detail
      # actions in a hashref
      elsif ( ref $action->{check} eq 'CODE' )
      {
         if ( !$action->{check}->($input) )
         {
            $error_message = 'Wrong value';
         }
      }
      elsif ( ref $action->{check} eq 'Regexp' )
      {
         if ( $input !~ $action->{check} )
         {
            $error_message = "\"$input\" does not match";
         }
      }
      elsif ( ref $action->{check} eq 'ARRAY' )
      {
         if ( !grep { $input eq $_ } @{ $action->{check} } )
         {
            $error_message = "\"$input\" not allowed";
         }
      }
      elsif ( ref $action->{transform} eq 'CODE' )
      {
         my $new_value = eval { 
            no warnings 'all';
            $action->{transform}->($input);
         };
         if ($@)
         {
            $error_message = $@ || 'error occurred';
         }
         else
         {
            # need to put in value so we know to skip
            # the default creation of value
            $self->value($new_value);
         }
      }
      if ( defined $error_message )
      {
         my @message = ($error_message);
         if ( ref $action->{message} )
         {
            @message = @{ $action->{message} };
         }
         elsif ( defined $action->{message} )
         {
            @message = ( $action->{message} );
         }
         $self->add_error(@message);
      }
   }
}

sub _apply_deflations
{
   my ( $self, $value )  = @_;

   for my $deflation ( @{ $self->deflations || [] } )
   {
       $value = $deflation->($value);
   }
   return $value;
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


=head2 input_defined

Returns true if $self->input contains any non-blank input.

=cut

sub input_defined
{
   my ($self) = @_;
   return unless $self->has_input;
   my $value = $self->input;
   # check for one value as defined
   return grep { /\S/ } @$value
      if ref $value eq 'ARRAY';
   return defined $value && $value =~ /\S/;
}

# removed pod to discourage use of fif_value
# This method will probably be replaced by deflate or something
# similar in the near future
sub fif_value
{
   my ( $self, $value ) = @_;
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
   warn "HFH: -----  ", $self->name, " -----\n";
   warn "HFH: type: ",  $self->type, "\n";
   warn "HFH: required: ", ( $self->required || '0' ), "\n";
   warn "HFH: label: ",  $self->label,  "\n";
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

__PACKAGE__->meta->make_immutable;
no HTML::FormHandler::Moose;
1;
