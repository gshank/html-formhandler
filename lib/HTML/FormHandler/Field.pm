package HTML::FormHandler::Field;

use HTML::FormHandler::Moose;
use MooseX::AttributeHelpers;
use HTML::FormHandler::I18N;    # only needed if running without a form object.

with 'HTML::FormHandler::TransformAndCheck';

our $VERSION = '0.02';

=head1 NAME

HTML::FormHandler::Field - Base class for HTML::FormHandler Fields

=head1 SYNOPSIS

Instances of Field subclasses are generally built by L<HTML::FormHandler>
from 'has_field' declarations or the field_list, but they can also be constructed
using new (usually for test purposes).

    use HTML::FormHandler::Field::Text;
    my $field = HTML::FormHandler::Field::Text->new( name => $name, ... );

In your custom field class:

    package MyApp::Field::MyText;
    extends 'HTML::FormHandler::Field::Text';

    has 'my_attribute' => ( isa => 'Str', is => 'rw' );

    apply [ { transform => sub {...}, message => '...' },
            { check => ['fighter', 'bard', 'mage' ], message => '....' }
          ];
    1;

=head1 DESCRIPTION

This is the base class for form fields. The 'type' of a field class
is used in the FormHandler field_list or has_field to identify which field class to
load. If the type is not specified, it defaults to Text.

There are two rough categories of Field classes: those that do extra processing
and those that are simple validators. The 'Compound', 'Repeatable', and
'Select' fields are fields that are functional.

A number of field classes are provided by the distribution. The basic
for-validation (as opposed to 'functional') field types are:

   Text
   Integer
   Boolean

These field types alone would be enough for most applications, since
the equivalent of the others could be defined using field attributes,
custom validation methods, and applied actions.  There is some benefit
to having descriptive names, of course, and if you have multiple fields
requiring the same validation, defining a custom field class may be a
good idea.

Inheritance hierarchy of the distribution's field classes:

   Compound
      Repeatable
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
   Boolean
      Checkbox
   DateMDY
   DateTime
   Email
   PrimaryKey 

See the documentation or source for the individual fields.

Many field classes contain only a list of constraints and transformations
to apply. Some use the 'validate' method, which is called after the actions
are applied. Some build a custom select list using 'build_options'.

=head1 ATTRIBUTES

=head2 Names, types, accessor

=over

=item name

The name of the field. Used in the HTML form. Often a db accessor.
The only required attribute.

=item type

The class or type of the field. The 'type' of L<HTML::FormHandler::Field::Money>
is 'Money'. Classes that you define yourself are prefixed with '+'.

=item accessor

If the name of your field is different than your database accessor, use
this attribute to provide the accessor.

=item full_name

The name of the field with all parents:

   'event.start_date.month'

=item full_accesor

The field accessor with all parents

=item html_name

The full_name plus the form name if 'html_prefix' is set.

=back

=head2 Field data

=over

=item inactive

Set this attribute if this field is inactive. This provides a way to define fields
in the form and selectively set them to inactive.

=item input

The input string from the parameters passed in.

=item value

The value as it would come from or go into the database, after being
acted on by transforms. Used to construct the C<< $form->values >>
hash. Validation and constraints act on 'value'.

=item fif

Values used to fill in the form. Read only. Use a deflation to get
from 'value' to 'fif' if the an inflator was used.

   [% form.field('title').fif %]

=item init_value

Initial value populated by init_from_object. You can tell if a field
has changed by comparing 'init_value' and 'value'. Read only.

=item input_without_param

Input for this field if there is no param. Needed for checkbox,
since an unchecked checkbox does not return a parameter.

=back

=head2 Form, parent

=over

=item form

A reference to the containing form.

=item parent

A reference to the parent of this field. Compound fields are the
parents for the fields they contain.

=back

=head2 Errors

=over

=item errors

Returns the error list for the field. Also provides 'num_errors',
'has_errors', 'push_errors' and 'clear_errors' from Collection::Array
metaclass. Use 'add_error' to add an error to the array if you
want to use a MakeText language handle. Default is an empty list.

=item add_error

Add an error to the list of errors.  If $field->form
is defined then process error message as Maketext input.
See $form->language_handle for details. Returns undef.

    return $field->add_error( 'bad data' ) if $bad;

=item error_fields

Compound fields will have an array of errors from the subfields.

=back

=head2 Attributes for creating HTML

   label - Text label for this field. Defaults to ucfirst field name.
   title - Place to put title for field.
   style - Place to put field style string
   css_class - For a css class name
   id    - Useful for javascript (default is form_name + field_name)
   disabled - for the HTML flag
   readonly - for the HTML flag
   javascript - for a Javascript string
   order - Used for sorting errors and fields. Built automatically,
           but may also be explicity set

=head2 widget

The 'widget' attribute is not used by base FormHandler code.
It is intended for use in generating HTML, in templates and the
rendering roles, and is used in L<HTML::FormHandler::Render::Simple>.
Fields of different type can use the same widget.

This attribute is set in the field classes, or in the fields
defined in the form. If you want a new widget type, use a new
name and provide a C<< 'widget_<name>' >> method in your copy
of Render::Simple or in your form class.
If you are using a template based rendering system you will want
to create a widget template.
(see L<HTML::FormHandler::Manual::Templates>)

Widget types for the provided field classes:

    Widget      : Field classes
    ------------:-----------------------------------
    text        : Text, Integer
    checkbox    : Checkbox, Boolean
    radio_group : Select, Multiple, IntRange (etc)
    select      : Select, Multiple, IntRange (etc)
    textarea    : TextArea, HtmlArea
    compound    : Compound, Repeatable, DateTime
    password    : Password
    hidden      : Hidden
    submit      : Submit

=head2 Flags

   password  - prevents the entered value from being displayed in the form
   writeonly - The initial value is not taken from the database
   noupdate  - Do not update this field in the database (does not appear in $form->value)

=head2 Form methods for fields

These provide the name of a method in a form (not the field ) which will act
on a particular field.

=over

=item set_validate

Specify a form method to be used to validate this field.
The default is C<< 'validate_' . $field->name >>. Periods in field names
will be replaced by underscores, so that the field 'addresses.city' will
use the 'validate_addresses_city' method for validation.

   has_field 'title' => ( isa => 'Str', set_validate => 'check_title' );
   has_field 'subtitle' => ( isa => 'Str', set_validate => 'check_title' );

=item set_init

The name of the method in the form that provides a field's initial value.
Default is C<< 'init_' . $field->name >>. Periods replaced by underscores.

=back

=head1 Constraints and Validations

=head2 Constraints set in attributes

=over

=item required

Flag indicating whether this field must have a value

=item required_message

Error message text added to errors if required field is not present
The default is "Field <field label> is required".

=item unique

Flag to initiate checks in the database model for uniqueness.

=item unique_message

Error message text added to errors if field is not unique

=item range_start

=item range_end

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

=back

=head2 apply

Use the 'apply' keyword to specify an ArrayRef of constraints and coercions to
be executed on the field at validate_field time.

   has_field 'test' => (
      apply => [ 'MooseType', { check => sub {...}, message => { } }
   );

In general the action can be of three types: a Moose type (which is
represented by its name), a transformation (which is a callback called on
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
failure. Messages are passed to L<Locale::MakeText>, and can either be simple
strings or an array suitable for MakeText, such as:

     message => ['Email should be of the format [_1]',
                 'someuser@example.com' ]

Transformations and coercions are called in an eval
to catch the errors. Warnings are trapped in a sigwarn handler.

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

You can see examples of field classes with 'apply' actions in the source for
L<HTML::FormHandler::Field::Money> and L<HTML::FormHandler::Field::Email>.

=head2 Moose types for constraints and transformations

Moose types can be used to do both constraints and transformations. If a coercion
exists it will be applied, resulting in a transformation. You can use type
constraints form L<MooseX::Types>> libraries or defined using
L<Moose::Util::TypeConstraints>.

A Moose type defined with L<Moose::Util::TypeConstraints>:
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

You can use them in a field like this (types defined with L<MooseX::Types>
would not be quoted):

   has_field 'some_text_to_int' => (
       apply => [ 'MyStr', 'MyInt' ]
   );

This will check if the field contains a string starting with 'a' - and then
coerce it to an integer by extracting the first continuous string of digits.

If the error message returned by the Moose type is not suitable for displaying
in a form, you can define a different error message by using the 'type' and
'message' keys in a hashref:

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

=head2 trim

A Hashref containing a transfrom to trim the field. By default
this contains a transform to strip beginning and trailing spaces.
Set this attribute to null to skip trimming, or supply a different
transform.

  trim => { transform => sub { } }

Trimming is performed before any other defined actions.

=head2 deflation, deflate

A 'deflation' is a coderef that will convert from an inflated value back to a 
flat data representation suitable for displaying in an HTML field.
A deflation is automatically used for data that is taken from the database.
For the fill-in-form value (fif) usually the fif string is taken straight from 
the input string if it exists, so if you want to use a deflated value instead, set
the 'fif_from_value' flag on the field. Normally you'd only need to do that if
you want to 'canonicalize' the entered data, such as if a user enters '09' for
the year and you want to re-display it as '2009'.

   has_field 'my_date_time' => (
      type => 'Compound',
      apply => [ { transform => sub{ DateTime->new( $_[0] ) } } ],
      deflation => sub { { year => $_->year, month => $_->month, day => $_->day } },
      fif_from_value => 1,
   );
   has_field 'my_date_time.year' => ( fif_from_value => 1 );
   has_field 'my_date_time.month';
   has_field 'my_date_time.day' => ( fif_from_value => 1 );

You can also use a 'deflate' method in a custom field class. See the Date field
for an example. If the deflation requires data that may vary (such as a format)
string and thus needs access to 'self', you would need to use the deflate method
since the deflation coderef is only passed the current value of the field

=head1 Processing and validating the field

=head2 validate_field

This is the base class validation routine. Most users will not
do anything with this. It might be useful for method modifiers,
if you want code that executed before or after the validation
process.

=head2 validate

This field method can be used in addition to or instead of 'apply' actions
in custom field classes.
It should validate the field data and set error messages on
errors with C<< $field->add_error >>.

    sub validate {
        my $field = shift;
        my $value = $field->value;
        return $field->add_error( ... ) if ( ... );
    }

=cut

has 'name' => ( isa => 'Str', is => 'rw', required => 1 );
has 'type' => ( isa => 'Str', is => 'rw', default => sub { ref shift } );
has 'init_value'       => ( is  => 'rw',   clearer   => 'clear_init_value' );
has 'parent'           => ( is  => 'rw',   predicate => 'has_parent' );
has 'errors_on_parent' => ( isa => 'Bool', is        => 'rw' );
sub has_fields { }
has 'input_without_param' => (
   is        => 'rw',
   predicate => 'has_input_without_param'
);
has 'reload_after_update' => ( is => 'rw', isa => 'Bool' );

has 'fif_from_value' => ( isa => 'Str', is => 'ro' );

sub fif
{
   my $self = shift;

   return if $self->inactive;
   return '' if $self->password;
   if ( ( $self->has_input && !$self->fif_from_value ) ||
      ( $self->fif_from_value && !defined $self->value ) )
   {
      return defined $self->input ? $self->input : '';
   }
   my $parent = $self->parent;
   if ( defined $parent &&
      $parent->isa('HTML::FormHandler::Field') &&
      ( $parent->has_deflation || $parent->can('deflate') ) )
   {
      my $parent_fif = $parent->fif;
      if ( ref $parent_fif eq 'HASH' &&
         exists $parent_fif->{ $self->name } )
      {
         return $self->_apply_deflation( $parent_fif->{ $self->name } );
      }
   }
   if ( defined $self->value ) {
      return $self->_apply_deflation( $self->value );
   }
   return '';
}

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
has 'temp' => ( is => 'rw' );
has 'label' => (
   isa     => 'Str',
   is      => 'rw',
   lazy    => 1,
   default => sub { ucfirst( shift->name ) },
);
has 'title'     => ( isa => 'Str',               is => 'rw' );
has 'style'     => ( isa => 'Str',               is => 'rw' );
has 'css_class' => ( isa => 'Str',               is => 'rw' );
has 'form'      => ( isa => 'HTML::FormHandler', is => 'rw', weak_ref => 1 );
has 'html_name' => (
   isa     => 'Str',
   is      => 'rw',
   lazy    => 1,
   builder => 'build_html_name'
);

sub build_html_name
{
   my $self = shift;
   my $prefix = ( $self->form && $self->form->html_prefix ) ? $self->form->name . "." : '';
   return $prefix . $self->full_name;
}
has 'widget'         => ( isa => 'Str',  is => 'rw' );
has 'order'          => ( isa => 'Int',  is => 'rw', default => 0 );
has 'inactive'       => ( isa => 'Bool', is => 'rw', clearer => 'clear_inactive' );
has 'unique'         => ( isa => 'Bool', is => 'rw' );
has 'unique_message' => ( isa => 'Str',  is => 'rw' );
has 'id'             => ( isa => 'Str',  is => 'rw', lazy => 1, builder => 'build_id' );
sub build_id { shift->html_name }
has 'javascript' => ( isa => 'Str',  is => 'rw' );
has 'password'   => ( isa => 'Bool', is => 'rw' );
has 'writeonly'  => ( isa => 'Bool', is => 'rw' );
has 'disabled'   => ( isa => 'Bool', is => 'rw' );
has 'readonly'   => ( isa => 'Bool', is => 'rw' );
has 'noupdate'   => ( isa => 'Bool', is => 'rw' );
has 'errors'     => (
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
sub validated { !shift->has_errors }
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
      unless $self->form &&
         $self->set_validate &&
         $self->form->can( $self->set_validate );
   return 1;
}

sub _validate
{
   my $self = shift;
   return unless $self->_can_validate;
   my $meth = $self->set_validate;
   $self->form->$meth($self);
}
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

sub _can_init_value
{
   my $self = shift;
   return
      unless $self->form &&
         $self->set_init &&
         $self->form->can( $self->set_init );
   return 1;
}

sub get_init_value
{
   my $self = shift;
   return unless $self->_can_init_value;
   my $meth = $self->set_init;
   $self->form->$meth( $self, $self->form->item );
}
has 'deflation' => (
   is        => 'rw',
   predicate => 'has_deflation',
);
has 'trim' => (
   isa     => 'HashRef',
   is      => 'rw',
   default => sub {
      {
         transform => sub {
            my $value = shift;
            return unless defined $value;
            my @values = ref $value eq 'ARRAY' ? @$value : ($value);
            for (@values) {
               next if ref $_;
               s/^\s+//;
               s/\s+$//;
            }
            return ref $value eq 'ARRAY' ? \@values : $values[0];
         },
      };
   }
);

sub BUILD
{
   my ( $self, $params ) = @_;

   $self->add_action( $self->trim ) if $self->trim;
   $self->_build_apply_list;
   $self->add_action( @{ $params->{apply} } ) if $params->{apply};
   $self->set_validate;    # to vivify
   $self->set_init;        # to vivify

}

# this is the recursive routine that is used
# to initial fields if there is no initial object and no params
sub _init
{
   my $self = shift;

   if ( my @values = $self->get_init_value ) {
      my $value = @values > 1 ? \@values : shift @values;
      $self->init_value($value) if $value;
      $self->value($value)      if $value;
   }
}

sub full_name
{
   my $field = shift;

   my $name = $field->name;
   my $parent = $field->parent || return $name;
   return $parent->full_name . '.' . $name;
}

sub full_accessor
{
   my $field = shift;

   my $accessor = $field->accessor;
   my $parent = $field->parent || return $accessor;
   return $parent->full_accessor . '.' . $accessor;
}

sub add_error
{
   my ( $self, @message ) = @_;

   my $lh;
   unless ( defined $message[0] ) {
      @message = ('field is invalid');
   }
   # Running without a form object?
   if ( $self->form ) {
      $lh = $self->form->language_handle;
   }
   else {
      $lh = $ENV{LANGUAGE_HANDLE} ||
         HTML::FormHandler::I18N->get_handle ||
         die "Failed call to Locale::Maketext->get_handle";
   }
   my $message = $lh->maketext(@message);
   $self->push_errors($message);
   return;
}

sub _apply_deflation
{
   my ( $self, $value ) = @_;

   if ( $self->has_deflation ) {
      $value = $self->deflation->($value);
   }
   elsif ( $self->can('deflate') ) {
      $value = $self->deflate;
   }
   return $value;
}

# use Class::MOP to clone
sub clone
{
   my ( $self, %params ) = @_;
   $self->meta->clone_object( $self, %params );
}

sub clear_data
{
   my $self = shift;
   $self->clear_input;
   $self->clear_value;
   #   $self->clear_fif;
   $self->clear_errors;
   $self->clear_init_value;
   $self->clear_other;
}
# clear_other used in Repeatable
sub clear_other { }

sub value_changed
{
   my ($self) = @_;

   my @cmp;
   for ( 'init_value', 'value' ) {
      my $val = $self->$_;
      $val = '' unless defined $val;
      push @cmp, join '|', sort
         map { ref($_) && $_->isa('DateTime') ? $_->iso8601 : "$_" }
         ref($val) eq 'ARRAY' ? @$val : $val;
   }
   return $cmp[0] ne $cmp[1];
}

sub required_text { shift->required ? 'required' : 'optional' }

sub render
{
   my $self = shift;
   return "<p>No form available to field " . $self->name . "</p>"
      unless $self->form;
   my $form_render_method = "render_" . $self->widget;
   return "<p>No render method available for field " . $self->name . "<p>"
      unless $self->form->can($form_render_method);
   return $self->form->$form_render_method;
}

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

   if ( $self->can('options') ) {
      my $o = $self->options;
      warn "HFH: options: " . Data::Dumper::Dumper $o;
   }
}

=head1 AUTHORS

HTML::FormHandler Contributors; see HTML::FormHandler

Initially based on the original source code of L<Form::Processor::Field> by Bill Moseley

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
no HTML::FormHandler::Moose;
1;
