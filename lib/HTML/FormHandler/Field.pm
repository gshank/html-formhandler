package HTML::FormHandler::Field;
# ABSTRACT: base class for fields

use HTML::FormHandler::Moose;
use HTML::FormHandler::Field::Result;
use Try::Tiny;
use Moose::Util::TypeConstraints;

with 'HTML::FormHandler::Traits';
with 'HTML::FormHandler::Validate';
with 'HTML::FormHandler::Widget::ApplyRole';
with 'HTML::FormHandler::TraitFor::Types';

our $VERSION = '0.02';

=head1 SYNOPSIS

Instances of Field subclasses are generally built by L<HTML::FormHandler>
from 'has_field' declarations or the field_list, but they can also be constructed
using new (usually for test purposes).

    use HTML::FormHandler::Field::Text;
    my $field = HTML::FormHandler::Field::Text->new( name => $name, ... );

In your custom field class:

    package MyApp::Field::MyText;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Text';

    has 'my_attribute' => ( isa => 'Str', is => 'rw' );

    apply [ { transform => sub { ... } },
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

=item full_accessor

The field accessor with all parents

=item html_name

The full_name plus the form name if 'html_prefix' is set.

=item input_param

By default we expect an input parameter based on the field name.  This allows
you to look for a different input parameter.

=back

=head2 Field data

=over

=item inactive, is_inactive, is_active

Set the 'inactive' attribute to 1 if this field is inactive. The 'inactive' attribute
that isn't set or is set to 0 will make a field 'active'.
This provides a way to define fields in the form and selectively set them to inactive.
There is also an '_active' attribute, for internal use to indicate that the field has
been activated/inactivated on 'process' by the form's 'active'/'inactive' attributes.

You can use the is_inactive and is_active methods to check whether this particular
field is active.

   if( $form->field('foo')->is_active ) { ... }

=item input

The input string from the parameters passed in.

=item value

The value as it would come from or go into the database, after being
acted on by transforms. Used to construct the C<< $form->values >>
hash. Validation and constraints act on 'value'.

=item fif

Values used to fill in the form. Read only. Use a deflation to get
from 'value' to 'fif' if an inflator was used. (Deflations can be
done in two different places. Set 'deflate_to' => 'fif' to deflate
in fillinform'.)

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
'has_errors', 'push_errors' and 'clear_errors' from Array
trait. Use 'add_error' to add an error to the array if you
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

There's a generic 'html_attr' hashref attribute that can be used to set
arbitrary HTML attributes on a field.

   has_field 'foo' => ( html_attr => { readonly => 1, my_attr => 'abc' } );

Some attributes also have specific setters
(readonly', 'disabled', 'style', 'title', 'tabindex).

   has_field 'bar' => ( readonly => 1 ); 
         
   title       - Place to put title for field.
   style       - Place to put field style string
   disabled    - for the HTML flag
   tabindex    - for the HTML tab index
   readonly    - for the HTML flag

The javascript value of the javascript attribute is entered completely.

   javascript  - for a Javascript string

The following are used in rendering HTML, but are handled specially.

   label       - Text label for this field. Defaults to ucfirst field name.
   css_class   - For a css class name (string; could be several classes,
                 separated by spaces or commas). Used in wrapper for input field.
   input_class - class attribute on the 'input' field. applied with
                 '_apply_html_attribute' (also html_attr => { class => '...' } ) 
   id          - Useful for javascript (default is html_name. to prefix with
                 form name, use 'html_prefix' in your form)
   render_filter - Coderef for filtering fields before rendering. By default
                 changes >, <, &, " to the html entities

The order attribute may be used to set the order in which fields are rendered.

   order       - Used for sorting errors and fields. Built automatically,
                 but may also be explicitly set

=head2 widget

The 'widget' attribute is used in rendering, so if you are
not using FormHandler's rendering facility, you don't need this
attribute.
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

If you are using the widget roles, you can specify the widget
with the short class name instead.

Widget types for the provided field classes:

    Widget         : Field classes
    ---------------:-----------------------------------
    text (Text)            : Text, Integer
    checkbox (Checkbox)    : Checkbox, Boolean
    radio_group
       (RadioGroup)        : Select, Multiple, IntRange (etc)
    select (Select)        : Select, Multiple, IntRange (etc)
    checkbox_group
       (CheckboxGroup)     : Multiple select
    textarea (Textarea)    : TextArea, HtmlArea
    compound (Compound)    : Compound, Repeatable, DateTime
    password (Password)    : Password
    hidden (Hidden)        : Hidden
    submit (Submit)        : Submit
    reset (Reset)          : Reset
    no_render (NoRender)   :
    upload (Upload)        : Upload

Widget roles are automatically applied to field classes
unless they already have a 'render' method. Render::Simple
will fall back to doing C<< $field->render >> if the corresponding
widget method does not exist.

You can create your own widget roles and specify the namespace
in 'widget_name_space'. In the form:

    has '+widget_name_space' => ( default => sub { ['MyApp::Widget'] } );

If you want to use a fully specified role name for a widget, you
can prefix it with a '+':

   widget => '+MyApp::Widget::SomeWidget'

For more about widgets, see L<HTML::FormHandler::Manual::Rendering>.

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

=item set_default

The name of the method in the form that provides a field's default value.
Default is C<< 'default_' . $field->name >>. Periods replaced by underscores.

=item default

Provide an initial value just like the 'set_default' method, except in the field
declaration:

  has_field 'bax' => ( default => 'Default bax' );

FormHandler has flipped back and forth a couple of times about whether a default
specified in the has_field definition should override values provided in an
initial item or init_object. Sometimes people want one behavior, and sometimes
the other. Now 'default' does *not* override.

If you pass in a model object with C<< item => $row >> or an initial object
with C<< init_object => {....} >> the values in that object will be used instead
of values provided in the field definition with 'default' or 'default_fieldname'.

If you *want* values that override the item/init_object, you can use the field
attribute 'default_over_obj'.

However you might want to consider putting your defaults into your row or init_object
instead.

=item default_over_obj

Allows setting defaults which will override values provided with an item/init_object.

   has_field 'quux' => ( default_over_obj => 'default quux' );

At this time there is no equivalent of 'set_default', but the type of the attribute
is not defined so you can provide default values in a variety of other ways,
including providing a trait which does 'build_default_over_obj'. For examples,
see tests in the distribution.

=back

=head1 Constraints and Validations

=head2 Constraints set in attributes

=over

=item required

Flag indicating whether this field must have a value

=item unique

For DB field - check for uniqueness. Action is performed by
the DB model.

=item messages

    messages => { required => '...', unique => '...' }

Set messages created by FormHandler by setting in the 'messages'
hashref. Some field subclasses have additional settable messages.

required:  Error message text added to errors if required field is not present
The default is "Field <field label> is required".

unique: message for when 'unique' is set, but field is not unique

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


=item not_nullable

Fields that contain 'empty' values such as '' are changed to undef in the validation process.
If this flag is set, the value is not changed to undef. If your database column requires
an empty string instead of a null value (such as a NOT NULL column), set this attribute.

    has_field 'description' => (
        type => 'TextArea',
        not_nullable => 1,
    );

This attribute is also used when you want an empty array to stay an empty array and not
be set to undef.

=back

=head2 apply

Use the 'apply' keyword to specify an ArrayRef of constraints and coercions to
be executed on the field at validate_field time.

   has_field 'test' => (
      apply => [ 'MooseType',
                 { check => sub {...}, message => { } },
                 { transform => sub { ... lc(shift) ... } }
               ],
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

In addition to being a string, Messages may be arrayrefs, for localization,
or coderefs, which will be passed a reference to the field and the original value.

   apply [ { check => ['abc'], message => \&err_message } ];
   sub err_message {
      my ( $value, $field ) = @_;
      return $field->name . ": must .... ";
   }

You can see examples of field classes with 'apply' actions in the source for
L<HTML::FormHandler::Field::Money> and L<HTML::FormHandler::Field::Email>, and
in t/constraints.t.

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
      ]
  );

A 'check' regular expression:

  has_field 'some_text' => (
      apply => [ { check => qr/aaa/, message => 'Must contain aaa' } ],
  );

A 'check' array of valid values:

  has_field 'more_text' => (
      apply => [ { check => ['aaa', 'bbb'], message => 'Must be aaa or bbb' } ]
  );

A simple transformation uses the 'transform' keyword and a coderef.
The coderef will be passed the current value of the field and should return
a transformed value.

  has_field 'sprintf_filter' => (
      apply => [ { transform => sub{ sprintf '<%.1g>', $_[0] } } ]
  );

=head2 trim

An action to trim the field. By default
this contains a transform to strip beginning and trailing spaces.
Set this attribute to null to skip trimming, or supply a different
transform.

  trim => { transform => sub {
      my $string = shift;
      $string =~ s/^\s+//;
      $string =~ s/\s+$//;
      return $string;
  } }
  trim => { type => MyTypeConstraint }

Trimming is performed before any other defined actions.

=head2 deflation, deflate

A 'deflation' is a coderef that will convert from an inflated value back to a
flat data representation suitable for displaying in an HTML field.
If deflation is defined for a field it is automatically used for data that is
taken from the database.

   has_field 'my_date_time' => (
      type => 'Compound',
      apply => [ { transform => sub{ DateTime->new( $_[0] ) } } ],
      deflation => sub { { year => $_[0]->year, month => $_[0]->month, day => $_[0]->day } },
      fif_from_value => 1,
   );
   has_field 'my_date_time.year';
   has_field 'my_date_time.month';
   has_field 'my_date_time.day';

You can also use a 'deflate' method in a custom field class. See the Date field
for an example. If the deflation requires data that may vary (such as a format)
string and thus needs access to 'self', you would need to use the deflate method
since the deflation coderef is only passed the current value of the field

Normally if you have a deflation, you will need a matching inflation, which can be
supplied via a 'transform' action. When using a 'transform', the 'value' hash only
contains reliably inflated values after validation has been performed, since
inflation is performed at validation time.

Deflation can be done at two different places: transforming the value that's saved
from the initial_object/item, or when retrieving the 'fif' (fill-in-form) value that's
displayed in the HTML form. The default is C<< deflate_to => 'value' >>. To deflate
when getting the 'fif' value set 'deflate_to' to 'fif'. (See t/deflate.t for examples.)

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
has 'parent' => ( is  => 'rw',   predicate => 'has_parent', weak_ref => 1 );
sub has_fields { }
has 'input_without_param' => (
    is        => 'rw',
    predicate => 'has_input_without_param'
);
has 'not_nullable' => ( is => 'rw', isa => 'Bool' );
has 'init_value' => ( is => 'rw', clearer => 'clear_init_value' );
has 'default' => ( is => 'rw' );
has 'default_over_obj' => ( is => 'rw', builder => 'build_default_over_obj' );
sub build_default_over_obj { }
has 'result' => (
    isa       => 'HTML::FormHandler::Field::Result',
    is        => 'ro',
    weak_ref  => 1,
    lazy      => 1,
    builder   => 'build_result',
    clearer   => 'clear_result',
    predicate => 'has_result',
    writer    => '_set_result',
    handles   => [
        '_set_input',   '_clear_input', '_set_value', '_clear_value',
        'errors',       'all_errors',   'push_errors',  'num_errors', 'has_errors',
        'clear_errors', 'validated',
    ],
);
has '_pin_result' => ( is => 'ro', reader => '_get_pin_result', writer => '_set_pin_result' );

sub has_input {
    my $self = shift;
    return unless $self->has_result;
    return $self->result->has_input;
}

sub has_value {
    my $self = shift;
    return unless $self->has_result;
    return $self->result->has_value;
}

# this should normally only be called for field tests
sub build_result {
    my $self = shift;
    my @parent = ( 'parent' => $self->parent->result )
        if ( $self->parent && $self->parent->result );
    my $result = HTML::FormHandler::Field::Result->new(
        name      => $self->name,
        field_def => $self,
        @parent
    );
    $self->_set_pin_result($result);    # to prevent garbage collection of result
    return $result;
}

sub input {
    my $self = shift;

    # allow testing fields individually by creating result if no form
    return undef unless $self->has_result || !$self->form; 
    my $result = $self->result;
    return $result->_set_input(@_) if @_;
    return $result->input;
}

sub value {
    my $self = shift;

    # allow testing fields individually by creating result if no form
    return undef unless $self->has_result || !$self->form; 
    my $result = $self->result;
    return $result->_set_value(@_) if @_;
    return $result->value;
}
# for compatibility. deprecate and remove at some point
sub clear_input { shift->_clear_input }
sub clear_value { shift->_clear_value }
sub clear_data  {
    my $self = shift;
    $self->clear_result;
    $self->clear_active;
}
# this is a kludge to allow testing field deflation
sub _deflate_and_set_value {
    my ( $self, $value ) = @_;
    if( $self->_can_deflate ) {
        $value = $self->_apply_deflation($value);
    }
    $self->_set_value($value);
}

sub is_repeatable { }
has 'reload_after_update' => ( is => 'rw', isa => 'Bool' );

has 'fif_from_value' => ( isa => 'Str', is => 'ro' );

sub fif {
    my ( $self, $result ) = @_;

    return if ( $self->inactive && !$self->_active );
    return '' if $self->password;
    return unless $result || $self->has_result;
    my $lresult = $result || $self->result;
    if ( ( $self->has_result && $self->has_input && !$self->fif_from_value ) ||
        ( $self->fif_from_value && !defined $lresult->value ) )
    {
        return defined $lresult->input ? $lresult->input : '';
    }
    if ( defined $lresult->value ) {
        if( $self->deflate_to eq 'fif' && $self->_can_deflate ) {
            return $self->_apply_deflation($lresult->value);
        }
        else {
            return $lresult->value;
        }
    }
    elsif ( defined $self->value ) {
        # this is because checkboxes and submit buttons have their own 'value'
        # needs to be fixed in some better way
        return $self->value;
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

sub has_flag {
    my ( $self, $flag_name ) = @_;
    return unless $self->can($flag_name);
    return $self->$flag_name;
}

has 'label' => (
    isa     => 'Str',
    is      => 'rw',
    lazy    => 1,
    builder => 'build_label',
);
has 'no_render_label' => ( isa => 'Bool', is => 'rw' );
sub build_label {
    my $self = shift;
    my $label = $self->name;
    $label =~ s/_/ /g;
    $label = ucfirst($label);
    return $label;
}
sub loc_label {
    my $self = shift;
    return $self->_localize($self->label);
}
has 'title'     => ( isa => 'Str',               is => 'rw' );
has 'style'     => ( isa => 'Str',               is => 'rw' );
has 'css_class' => ( isa => 'Str',               is => 'rw' );
has 'input_class' => ( isa => 'Str',             is => 'rw' );
has 'form'      => (
    isa => 'HTML::FormHandler',
    is => 'rw',
    weak_ref => 1,
    predicate => 'has_form',
);
has 'html_name' => (
    isa     => 'Str',
    is      => 'rw',
    lazy    => 1,
    builder => 'build_html_name'
);

sub build_html_name {
    my $self = shift;
    my $prefix = ( $self->form && $self->form->html_prefix ) ? $self->form->name . "." : '';
    return $prefix . $self->full_name;
}
has 'widget'            => ( isa => 'Str',  is => 'rw' );
has 'widget_wrapper'    => ( isa => 'Str',  is => 'rw' );
has 'widget_tags'         => (
    traits => ['Hash'],
    isa => 'HashRef',
    is => 'ro',
    default => sub {{}},
    handles => {
      get_tag => 'get',
      set_tag => 'set',
      tag_exists => 'exists',
    },
);
has 'widget_name_space' => (
    isa => 'HFH::ArrayRefStr',
    is => 'rw',
    default => sub {[]},
    coerce => 1,
);
sub add_widget_name_space {
    my ( $self, @ns ) = @_;
    @ns = @{$ns[0]}if( scalar @ns && ref $ns[0] eq 'ARRAY' );
    my $widget_ns = $self->widget_name_space;
    push @{$self->widget_name_space}, @ns;
}
has 'order'             => ( isa => 'Int',  is => 'rw', default => 0 );
# 'inactive' is set in the field declaration, and is static. Default status.
has 'inactive'          => ( isa => 'Bool', is => 'rw', clearer => 'clear_inactive' );
# 'active' is cleared whenever the form is cleared. Ephemeral activation.
has '_active'         => ( isa => 'Bool', is => 'rw', clearer => 'clear_active', predicate => 'has__active' );
sub is_active {
    my $self = shift;
    return ! $self->is_inactive;
}
sub is_inactive {
    my $self = shift;
    return (($self->inactive && !$self->_active) || (!$self->inactive && $self->has__active && $self->_active == 0 ) );
}
has 'id'                => ( isa => 'Str',  is => 'rw', lazy => 1, builder => 'build_id' );
sub build_id { shift->html_name }

# html attributes
has 'javascript' => ( isa => 'Str',  is => 'rw' );
has 'password'   => ( isa => 'Bool', is => 'rw' );
has 'writeonly'  => ( isa => 'Bool', is => 'rw' );
has 'disabled'   => ( isa => 'Bool', is => 'rw' );
has 'readonly'   => ( isa => 'Bool', is => 'rw' );
has 'tabindex' => ( is => 'rw', isa => 'Int' );
has 'html_attr' => ( is => 'rw', traits => ['Hash'],
   default => sub { {} }, handles => { has_html_attr => 'count',
   set_html_attr => 'set', delete_html_attr => 'delete' }
);

has 'noupdate'   => ( isa => 'Bool', is => 'rw' );
has 'set_validate' => ( isa => 'Str', is => 'ro',);
sub _can_validate {
    my $self = shift;
    my $set_validate = $self->_set_validate_meth;
    return
        unless $self->form &&
            $set_validate &&
            $self->form->can( $set_validate );
    return $set_validate;
}
sub _set_validate_meth {
    my $self = shift;
    return $self->set_validate if $self->set_validate;
    my $name = $self->full_name;
    if( $name =~ /\./ ) {
        $name =~ s/\.\d+\./_/g;
        $name =~ s/\./_/g;
    }
    return 'validate_' . $name;
}
sub _validate {
    my $self = shift;
    return unless (my $meth = $self->_can_validate);
    $self->form->$meth($self);
}
has 'set_default' => ( isa => 'Str', is => 'ro', writer => '_set_default');
sub _can_default {
    my $self = shift;
    my $set_default = $self->_set_default_meth;
    return
        unless $self->form &&
            $set_default &&
            $self->form->can( $set_default );
    return $set_default;
}
sub _comp_default_meth {
    my $self = shift;
    my $name = $self->full_name;
    if( $name =~ /\./ ) {
        $name =~ s/\.\d+\./_/g;
        $name =~ s/\./_/g;
    }
    return 'init_value_' . $name;
}
sub _set_default_meth {
    my $self = shift;
    return $self->set_default if $self->set_default;
    my $name = $self->full_name;
    if( $name =~ /\./ ) {
        $name =~ s/\.\d+\./_/g;
        $name =~ s/\./_/g;
    }
    return 'default_' . $name;
}
sub get_default_value {
    my $self = shift;
    if ( my $meth = $self->_can_default ) {
        return $self->form->$meth( $self, $self->form->item );
    }
    elsif ( defined $self->default ) {
        return $self->default;
    }
    return;
}
has 'deflation' => (
    is        => 'rw',
    predicate => 'has_deflation',
);
# deflate_to either 'value' or 'fif'
has 'deflate_to' => ( is => 'rw', default => 'value' );
has 'trim' => (
    is      => 'rw',
    default => sub { { transform => \&default_trim } }
);

sub default_trim {
    my $value = shift;
    return unless defined $value;
    my @values = ref $value eq 'ARRAY' ? @$value : ($value);
    for (@values) {
        next if ref $_ or !defined;
        s/^\s+//;
        s/\s+$//;
    }
    return ref $value eq 'ARRAY' ? \@values : $values[0];
}
has 'render_filter' => (
     traits => ['Code'],
     is     => 'ro',
     isa    => 'CodeRef',
     builder => 'build_render_filter',
     handles => { html_filter => 'execute' },
);

sub build_render_filter {
    my $self = shift;

    if( $self->form && $self->form->can('render_filter') ) {
        my $coderef = $self->form->can('render_filter');
        return $coderef;
    }
    else {
        return \&default_render_filter;
    }
}

sub default_render_filter {
    my $string = shift;
    return '' if (!defined $string);
    $string =~ s/&/&amp;/g;
    $string =~ s/</&lt;/g;
    $string =~ s/>/&gt;/g;
    $string =~ s/"/&quot;/g;
    return $string;
}

has 'input_param' => ( is => 'rw', isa => 'Str' );

has 'language_handle' => (
    isa => duck_type( [ qw(maketext) ] ),
    is => 'rw',
    reader => 'get_language_handle',
    writer => 'set_language_handle',
    predicate => 'has_language_handle'
);

sub language_handle {
    my ( $self, $value ) = @_;
    if( $value ) {
        $self->set_language_handle($value);
        return;
    }
    return $self->get_language_handle if( $self->has_language_handle );
    return $self->form->language_handle if ( $self->has_form );
    require HTML::FormHandler::I18N;
    return $ENV{LANGUAGE_HANDLE} || HTML::FormHandler::I18N->get_handle;
}

has 'localize_meth' => (
     traits => ['Code'],
     is     => 'ro',
     isa    => 'CodeRef',
     builder => 'build_localize_meth',
     handles => { '_localize' => 'execute_method' },
);

sub build_localize_meth {
    my $self = shift;

    if( $self->form && $self->form->can('localize_meth') ) {
        my $coderef = $self->form->can('localize_meth');
        return $coderef;
    }
    else {
        return \&default_localize;
    }
}

sub default_localize {
    my ($self, @message) = @_;
    my $message = $self->language_handle->maketext(@message);
    return $message;
}

has 'messages' => ( is => 'rw',
    isa => 'HashRef',
    traits => ['Hash'],
    default => sub {{}},
    handles => {
        '_get_field_message' => 'get',
        '_has_field_message' => 'exists',
        'set_message' => 'set',
    },
);

our $class_messages = {
    'field_invalid'   => 'field is invalid',
    'range_too_low'   => 'Value must be greater than or equal to [_1]',
    'range_too_high'  => 'Value must be less than or equal to [_1]',
    'range_incorrect' => 'Value must be between [_1] and [_2]',
    'wrong_value'     => 'Wrong value',
    'no_match'        => '[_1] does not match',
    'not_allowed'     => '[_1] not allowed',
    'error_occurred'  => 'error occurred',
    'required'        => '[_1] field is required',
};

sub get_class_messages  {
    my $self = shift;
    my $messages = { %$class_messages };
    $messages->{required} = $self->required_message
        if $self->required_message;
    return $messages;
}

sub get_message {
    my ( $self, $msg ) = @_;

    # first look in messages set on individual field
    return $self->_get_field_message($msg)
       if $self->_has_field_message($msg);
    # then look at form messages
    return $self->form->_get_form_message($msg)
       if $self->has_form && $self->form->_has_form_message($msg);
    # then look for messages up through inherited field classes
    return $self->get_class_messages->{$msg};
}
sub all_messages {
    my $self = shift;
    my $form_messages = $self->has_form ? $self->form->messages : {};
    my $field_messages = $self->messages || {};
    my $lclass_messages = $self->my_class_messages || {};
    return {%{$lclass_messages}, %{$form_messages}, %{$field_messages}};
}

sub BUILDARGS {
    my $class = shift;

    # for compatibility, change 'set_init' to 'set_default'
    my @new;
    push @new, ('set_default', {@_}->{set_init} )
        if( exists {@_}->{set_init} );
    return $class->SUPER::BUILDARGS(@_, @new);
}

sub BUILD {
    my ( $self, $params ) = @_;

    $self->_set_default( $self->_comp_default_meth )
        if( $self->form && $self->form->can( $self->_comp_default_meth ) );
    $self->add_widget_name_space( $self->form->widget_name_space ) if $self->form;
    # widgets will already have been applied by BuildFields, but this allows
    # testing individual fields
#   $self->apply_rendering_widgets unless ($self->can('render') );
    $self->add_action( $self->trim ) if $self->trim;
    $self->_build_apply_list;
    $self->add_action( @{ $params->{apply} } ) if $params->{apply};
}

# this is the recursive routine that is used
# to initial fields if there is no initial object and no params
sub _result_from_fields {
    my ( $self, $result ) = @_;

    if ( my @values = $self->get_default_value ) {
        if ( $self->_can_deflate && $self->deflate_to eq 'value' ) {
            @values = $self->_apply_deflation(@values);
        }
        my $value = @values > 1 ? \@values : shift @values;
        $self->init_value($value)   if defined $value;
        $result->_set_value($value) if defined $value;
    }
    $self->_set_result($result);
    $result->_set_field_def($self);
    return $result;
}

sub _result_from_input {
    my ( $self, $result, $input, $exists ) = @_;

    if ($exists) {
        $result->_set_input($input);
    }
    elsif ( $self->has_input_without_param ) {
        $result->_set_input( $self->input_without_param );
    }
    $self->_set_result($result);
    $result->_set_field_def($self);
    return $result;
}

sub _result_from_object {
    my ( $self, $result, $value ) = @_;

    $self->_set_result($result);

    if ( $self->form ) {
        $self->form->init_value( $self, $value );
    }
    else {
        $self->init_value($value);
        $result->_set_value($value);
    }
    $result->_set_value(undef) if $self->writeonly;
    $result->_set_field_def($self);
    return $result;
}

sub full_name {
    my $field = shift;

    my $name = $field->name;
    my $parent = $field->parent || return $name;
    return $parent->full_name . '.' . $name;
}

sub full_accessor {
    my $field = shift;

    my $accessor = $field->accessor;
    my $parent = $field->parent || return $accessor;
    return $parent->full_accessor . '.' . $accessor;
}

sub add_error {
    my ( $self, @message ) = @_;

    unless ( defined $message[0] ) {
        @message = ( $class_messages->{field_invalid});
    }
    @message = @{$message[0]} if ref $message[0] eq 'ARRAY';
    my $out;
    try {
        $out = $self->_localize(@message);
    }
    catch {
        die "Error occurred localizing error message for " . $self->label . ".  $_";
    };

    $self->push_errors($out);
    return;
}

sub _apply_deflation {
    my ( $self, $value ) = @_;

    if ( $self->has_deflation ) {
        $value = $self->deflation->($value);
    }
    elsif ( $self->can('deflate') ) {
        $value = $self->deflate($value);
    }
    return $value;
}
sub _can_deflate {
    my $self = shift;
    return $self->has_deflation || $self->can('deflate');
}

# use Class::MOP to clone
sub clone {
    my ( $self, %params ) = @_;
    $self->meta->clone_object( $self, %params );
}

sub value_changed {
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

sub input_defined {
    my ($self) = @_;
    return unless $self->has_input;
    return has_some_value( $self->input );
}

sub dump {
    my $self = shift;

    require Data::Dumper;
    warn "HFH: -----  ", $self->name, " -----\n";
    warn "HFH: type: ",  $self->type, "\n";
    warn "HFH: required: ", ( $self->required || '0' ), "\n";
    warn "HFH: label: ",  $self->label,  "\n";
    warn "HFH: widget: ", $self->widget || '', "\n";
    my $v = $self->value;
    warn "HFH: value: ", Data::Dumper::Dumper($v) if $v;
    my $iv = $self->init_value;
    warn "HFH: init_value: ", Data::Dumper::Dumper($iv) if $iv;
    my $i = $self->input;
    warn "HFH: input: ", Data::Dumper::Dumper($i) if $i;
    my $fif = $self->fif;
    warn "HFH: fif: ", Data::Dumper::Dumper($fif) if $fif;

    if ( $self->can('options') ) {
        my $o = $self->options;
        warn "HFH: options: " . Data::Dumper::Dumper($o);
    }
}

sub apply_rendering_widgets {
    my $self = shift;

    if ( $self->widget ) {
        warn "in apply_rendering_widgets " . $self->widget . " Field\n";
        $self->apply_widget_role( $self, $self->widget, 'Field' );
    }
    my $widget_wrapper = $self->widget_wrapper;
    $widget_wrapper ||= $self->form->widget_wrapper if $self->form;
    $widget_wrapper ||= 'Simple';
    unless ( $widget_wrapper eq 'none' ) {
        $self->apply_widget_role( $self, $widget_wrapper, 'Wrapper' );
    }
    return;

}

sub peek {
    my ( $self, $indent ) = @_;

    $indent ||= '';
    my $string = $indent . 'field: "' . $self->name . '"  type: ' . $self->type . "\n";
    if( $self->has_flag('has_contains') ) {
        $string .= $indent . "contains: \n";
        my $lindent = $indent . '  ';
        foreach my $field ( $self->contains->sorted_fields ) {
            $string .= $field->peek( $lindent );
        }
    }
    if( $self->has_fields ) {
        $string .= $indent . 'subfields of "' . $self->name . '": ' . $self->num_fields . "\n";
        my $lindent = $indent . '  ';
        foreach my $field ( $self->sorted_fields ) {
            $string .= $field->peek( $lindent );
        }
    }
    return $string;
}

sub has_some_value {
    my $x = shift;

    return unless defined $x;
    return $x =~ /\S/ if !ref $x;
    if ( ref $x eq 'ARRAY' ) {
        for my $elem (@$x) {
            return 1 if has_some_value($elem);
        }
        return 0;
    }
    if ( ref $x eq 'HASH' ) {
        for my $key ( keys %$x ) {
            return 1 if has_some_value( $x->{$key} );
        }
        return 0;
    }
    return 1 if blessed($x);    # true if blessed, otherwise false
    return 1 if ref( $x );
    return;
}

sub apply_traits {
    my ($class, @traits) = @_;

    $class->meta->make_mutable;
    Moose::Util::apply_all_roles($class->meta, @traits);
    $class->meta->make_immutable;
}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
