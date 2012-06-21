package HTML::FormHandler::Field;
# ABSTRACT: base class for fields

use HTML::FormHandler::Moose;
use HTML::FormHandler::Field::Result;
use Try::Tiny;
use Moose::Util::TypeConstraints;
use HTML::FormHandler::Merge ('merge');
use HTML::FormHandler::Render::Util('cc_widget', 'ucc_widget');
use Sub::Name;

with 'HTML::FormHandler::Traits';
with 'HTML::FormHandler::Validate';
with 'HTML::FormHandler::Widget::ApplyRole';
with 'HTML::FormHandler::TraitFor::Types';

our $VERSION = '0.02';

=head1 SYNOPSIS

Instances of Field subclasses are generally built by L<HTML::FormHandler>
from 'has_field' declarations or the field_list, but they can also be constructed
using new for test purposes (since there's no standard way to add a field to a form
after construction).

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
load from the 'field_name_space' (or directly, when prefixed with '+').
If the type is not specified, it defaults to Text.

See L<HTML::FormHandler::Manual::Fields> for a list of the fields and brief
descriptions of their structure.

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

The field accessor with all parents.

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
acted on by inflations/deflations and transforms. Used to construct the
C<< $form->values >> hash. Validation and constraints act on 'value'.

See also L<HTML::FormHandler::Manual::InflationDeflation>.

=item fif

Values used to fill in the form. Read only. Use a deflation to get
from 'value' to 'fif' if an inflator was used. Use 'fif_from_value'
attribute if you want to use the field 'value' to fill in the form.

   [% form.field('title').fif %]

=item init_value

Initial value populated by init_from_object. You can tell if a field
has changed by comparing 'init_value' and 'value'. Read only.

=item input_without_param

Input for this field if there is no param. Set by default for Checkbox,
and Select, since an unchecked checkbox or unselected pulldown
does not return a parameter.

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

Add an error to the list of errors. Error message will be localized
using '_localize' method.
See also L<HTML::FormHandler::TraitFor::I18N>.

    return $field->add_error( 'bad data' ) if $bad;

=item error_fields

Compound fields will have an array of errors from the subfields.

=item localize_meth

Set the method used to localize.

=back

=head2 Attributes for creating HTML

The 'element_attr' hashref attribute can be used to set
arbitrary HTML attributes on a field's input tag.

   has_field 'foo' => ( element_attr => { readonly => 1, my_attr => 'abc' } );

Note that the 'id' and 'type' attributes are not set using element_attr. Use
the field's 'id' attribute (or 'build_id_method') to set the id.

The 'label_attr' hashref is for label attributes, and the 'wrapper_attr'
is for attributes on the wrapping element (a 'div' for the standard 'simple'
wrapper).

A 'javascript' key in one of the '_attr' hashes will be inserted into the
element as-is.

The following are used in rendering HTML, but are handled specially.

   label       - Text label for this field. Defaults to ucfirst field name.
   build_label_method - coderef for constructing the label
   wrap_label_method - coderef for constructing a wrapped label
   id          - Useful for javascript (default is html_name. to prefix with
                 form name, use 'html_prefix' in your form)
   build_id_method - coderef for constructing the id
   render_filter - Coderef for filtering fields before rendering. By default
                 changes >, <, &, " to the html entities
   disabled    - Boolean to set field disabled

The order attribute may be used to set the order in which fields are rendered.

   order       - Used for sorting errors and fields. Built automatically,
                 but may also be explicitly set

The following are discouraged. Use 'element_attr', 'label_attr', and 'wrapper_attr'
instead.

   css_class   - instead use wrapper_attr => { class => '...' }
   input_class - instead use element_attr => { class => '...' }
   title       - instead use element_attr => { title => '...' }
   style       - instead use element_attr => { style => '...' }
   tabindex    - instead use element_attr => { tabindex => 1 }
   readonly    - instead use element_attr => { readonly => 'readonly' }

Rendering of the various HTML attributes is done by calling the 'process_attrs'
function (from HTML::FormHandler::Render::Util) and passing in a method that
adds in error classes, provides backward compatibility with the deprecated
attributes, etc.

    attribute hashref  class attribute       wrapping method
    =================  =================     ================
    element_attr       element_class         element_attributes
    label_attr         label_class           label_attributes
    wrapper_attr       wrapper_class         wrapper_attributes

The slots for the class attributes are arrayrefs; they will coerce a
string into an arrayref.
In addition, these 'wrapping methods' call a hook method in the form class,
'html_attributes', which you can use to customize and localize the various
attributes. (Field types: 'element', 'wrapper', 'label')

   sub html_attributes {
       my ( $self, $field, $type, $attr ) = @_;
       $attr->{class} = 'label' if $type eq 'label';
       return $attr;
   }

The 'process_attrs' function will also handle an array of strings, such as for the
'class' attribute.

=head2 tags

A hashref containing flags and strings for use in the rendering code.
The value of a tag can be a string, a coderef (accessed as a method on the
field) or a block specified with a percent followed by the blockname
('%blockname').

Retrieve a tag with 'get_tag'. It returns a '' if the tag doesn't exist.

This attribute used to be named 'widget_tags', which is deprecated.

=head2 html5_type_attr [string]

This string is used when rendering the input tag as the value for the type attribute.
It is used when the form has the is_html5 flag on.

=head2 widget

The 'widget' attribute is used in rendering, so if you are
not using FormHandler's rendering facility, you don't need this
attribute.  It is used in generating HTML, in templates and the
rendering roles. Fields of different type can use the same widget.

This attribute is set in the field classes, or in the fields
defined in the form. If you want a new widget type, create a
widget role, such as MyApp::Form::Widget::Field::MyWidget. Provide
the name space in the 'widget_name_space' attribute, and set
the 'widget' of your field to the package name after the
Field/Form/Wrapper:

   has_field 'my_field' => ( widget => 'MyWidget' );

If you are using a template based rendering system you will want
to create a widget template.
(see L<HTML::FormHandler::Manual::Templates>)

Widget types for some of the provided field classes:

    Widget                 : Field classes
    -----------------------:---------------------------------
    Text                   : Text, Integer
    Checkbox               : Checkbox, Boolean
    RadioGroup             : Select, Multiple, IntRange (etc)
    Select                 : Select, Multiple, IntRange (etc)
    CheckboxGroup          : Multiple select
    TextArea               : TextArea, HtmlArea
    Compound               : Compound, Repeatable, DateTime
    Password               : Password
    Hidden                 : Hidden
    Submit                 : Submit
    Reset                  : Reset
    NoRender               :
    Upload                 : Upload

Widget roles are automatically applied to field classes
unless they already have a 'render' method, and if the
'no_widgets' flag in the form is not set.

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


=head2 Defaults

See also the documentation on L<HTML::FormHandler::Manual::Intro/Defaults>.

=over

=item default_method, set_default

Supply a coderef (which will be a method on the field) with 'default_method'
or the name of a form method with 'set_default' (which will be a method on
the form). If not specified and a form method with a name of
C<< default_<field_name> >> exists, it will be used.

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
If you want defaults that override the item/init_object, you can use the form
flags 'use_defaults_over_obj' and 'use_init_obj_over_item'.

You could also put your defaults into your row or init_object instead.

=item default_over_obj

This is deprecated; look into using 'use_defaults_over_obj' or 'use_init_obj_over_item'
flags instead. They allow using the standard 'default' attribute.

Allows setting defaults which will override values provided with an item/init_object.
(And only those. Will not be used for defaults without an item/init_object.)

   has_field 'quux' => ( default_over_obj => 'default quux' );

At this time there is no equivalent of 'set_default', but the type of the attribute
is not defined so you can provide default values in a variety of other ways,
including providing a trait which does 'build_default_over_obj'. For examples,
see tests in the distribution.

=back

=head1 Constraints and Validations

See also L<HTML::FormHandler::Manual::Validation>.

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

required:  Error message text added to errors if required field is not present.
The default is "Field <field label> is required".

=item range_start

=item range_end

Field values are validated against the specified range if one
or both of range_start and range_end are set and the field
does not have 'options'.

The IntRange field uses this range to create a select list
with a range of integers.

In a FormHandler field_list:

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

See more documentation in L<HTML::FormHandler::Manual::Validation>.

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

=head2 Inflation/deflation

There are a number of methods to provide finely tuned inflation and deflation:

=over 4

=item inflate_method

Inflate to a data format desired for validation.

=item deflate_method

Deflate to a string format for presenting in HTML.

=item inflate_default_method

Modify the 'default' provided by an 'item' or 'init_object'.

=item deflate_value_method

Modify the value returned by C<< $form->value >>.

=item deflation

Another way of providing a deflation method.

=item transform

Another way of providing an inflation method.

=back

Normally if you have a deflation, you will need a matching inflation.
There are two different flavors of inflation/deflation: one for inflating values
to a format needed for validation and deflating for output, the other for
inflating the initial provided values (usually from a database row) and deflating
them for the 'values' returned.

See L<HTML::FormHandler::Manual::InflationDeflation>.

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

=head2 validate_method, set_validate

Supply a coderef (which will be a method on the field) with 'validate_method'
or the name of a form method with 'set_validate' (which will be a method on
the form). If not specified and a form method with a name of
C<< validate_<field_name> >> exists, it will be used.

Periods in field names will be replaced by underscores, so that the field
'addresses.city' will use the 'validate_addresses_city' method for validation.

   has_field 'my_foo' => ( validate_method => \&my_foo_validation );
   sub my_foo_validation { ... }
   has_field 'title' => ( isa => 'Str', set_validate => 'check_title' );


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
has 'validate_when_empty' => ( is => 'rw', isa => 'Bool' );
has 'init_value' => ( is => 'rw', clearer => 'clear_init_value', predicate => 'has_init_value' );
has 'default' => ( is => 'rw' );
has 'default_over_obj' => ( is => 'rw', builder => 'build_default_over_obj' );
sub build_default_over_obj { }
has 'result' => (
    isa       => 'HTML::FormHandler::Field::Result',
    is        => 'ro',
    weak_ref  => 1,
    clearer   => 'clear_result',
    predicate => 'has_result',
    writer    => '_set_result',
    handles   => [
        '_set_input',   '_clear_input', '_set_value', '_clear_value',
        'errors',       'all_errors',   '_push_errors',  'num_errors', 'has_errors',
        'clear_errors', 'validated', 'add_warning', 'all_warnings', 'num_warnings',
        'has_warnings', 'warnings',
    ],
);
has '_pin_result' => ( is => 'ro', reader => '_get_pin_result', writer => '_set_pin_result' );

sub missing {
    my $self = shift;
    return $self->required && $self->validated && ( !$self->has_input || !$self->input_defined );
}

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

# these should normally only be called for field tests
sub reset_result {
    my $self = shift;
    $self->clear_result;
    $self->build_result;
}
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
    $self->_set_result($result);
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
    return undef unless $result;
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
        if( $self->_can_deflate ) {
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
has 'is_contains' => ( is => 'rw', isa => 'Bool' );
has 'temp' => ( is => 'rw' );

sub has_flag {
    my ( $self, $flag_name ) = @_;
    return unless $self->can($flag_name);
    return $self->$flag_name;
}

has 'label' => (
    isa     => 'Maybe[Str]',
    is      => 'rw',
    lazy    => 1,
    builder => 'build_label',
);
has 'do_label' => ( isa => 'Bool', is => 'rw', default => 1 );
has 'build_label_method' => ( is => 'rw', isa => 'CodeRef',
    traits => ['Code'], handles => { 'build_label' => 'execute_method' },
    default => sub { \&default_build_label },
);
sub default_build_label {
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
has 'wrap_label_method' => (
   traits => ['Code'],
   is     => 'ro',
   isa    => 'CodeRef',
   predicate => 'does_wrap_label',
   handles => { 'wrap_label' => 'execute_method' },
);
has 'title'     => ( isa => 'Str', is => 'rw' );
has 'style'     => ( isa => 'Str', is => 'rw' );
# deprecated; remove in six months.
has 'css_class' => ( isa => 'Str', is => 'rw', trigger => \&_css_class_set );
sub _css_class_set {
    my ( $self, $value ) = @_;
    $self->add_wrapper_class($value);
}
# deprecated; remove in six months;
has 'input_class' => ( isa => 'Str', is => 'rw', trigger => \&_input_class_set );
sub _input_class_set {
    my ( $self, $value ) = @_;
    $self->add_element_class($value);
}
has 'form'      => (
    isa => 'HTML::FormHandler',
    is => 'rw',
    weak_ref => 1,
    predicate => 'has_form',
);
sub is_form { 0 }
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
has 'do_wrapper'    => ( is => 'rw', default => 1 );
sub wrapper { shift->widget_wrapper || '' }
sub uwrapper { ucc_widget( shift->widget_wrapper || '' ) || 'simple' }
sub twrapper { shift->uwrapper . ".tt" }
sub uwidget { ucc_widget( shift->widget || '' ) || 'simple' }
sub twidget { shift->uwidget . ".tt" }
# deprecated. use 'tags' instead.
has 'widget_tags' => (
    isa => 'HashRef',
    traits => ['Hash'],
    is => 'rw',
    default => sub {{}},
    handles => {
        has_widget_tags => 'count'
    }
);
has 'tags'         => (
    traits => ['Hash'],
    isa => 'HashRef',
    is => 'rw',
    builder => 'build_tags',
    handles => {
      _get_tag => 'get',
      set_tag => 'set',
      has_tag => 'exists',
      tag_exists => 'exists',
      delete_tag => 'delete',
    },
);
sub build_tags {{}}
sub merge_tags {
    my ( $self, $new ) = @_;
    my $old = $self->tags;
    $self->tags( merge($new, $old) );
}
sub get_tag {
    my ( $self, $name ) = @_;
    return '' unless $self->tag_exists($name);
    my $tag = $self->_get_tag($name);
    return $self->$tag if ref $tag eq 'CODE';
    return $tag unless $tag =~ /^%/;
    ( my $block_name = $tag ) =~ s/^%//;
    return $self->form->block($block_name)->render
        if ( $self->form && $self->form->block_exists($block_name) );
    return '';
}

has 'widget_name_space' => (
    isa => 'HFH::ArrayRefStr',
    is => 'rw',
    traits => ['Array'],
    default => sub {[]},
    coerce => 1,
    handles => {
        push_widget_name_space => 'push',
    },
);

sub add_widget_name_space {
    my ( $self, @ns ) = @_;
    @ns = @{$ns[0]}if( scalar @ns && ref $ns[0] eq 'ARRAY' );
    $self->push_widget_name_space(@ns);
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
has 'build_id_method' => ( is => 'rw', isa => 'CodeRef', traits => ['Code'],
    default => sub { sub { shift->html_name } },
    handles => { build_id => 'execute_method' },
);

# html attributes
has 'password'   => ( isa => 'Bool', is => 'rw' );
has 'disabled'   => ( isa => 'Bool', is => 'rw' );
has 'readonly'   => ( isa => 'Bool', is => 'rw' );
has 'tabindex' => ( is => 'rw', isa => 'Int' );

has 'type_attr' => ( is => 'rw', isa => 'Str', default => 'text' );
has 'html5_type_attr' => ( isa => 'Str', is => 'ro', default => 'text' );
sub input_type {
    my $self = shift;
    return $self->html5_type_attr if ( $self->form && $self->form->has_flag('is_html5') );
    return $self->type_attr;
}
# temporary methods for compatibility after name change
sub html_attr { shift->element_attr(@_) }
sub has_html_attr { shift->has_element_attr(@_) }
sub get_html_attr { shift->get_element_attr(@_) }
sub set_html_attr { shift->set_element_attr(@_) }

{
    # create the attributes and methods for
    # element_attr, build_element_attr, element_class,
    # label_attr, build_label_attr, label_class,
    # wrapper_attr, build_wrapper_atrr, wrapper_class
    no strict 'refs';
    foreach my $attr ('wrapper', 'element', 'label' ) {
        # trigger to move 'class' set via _attr to the class slot
        my $add_meth = "add_${attr}_class";
        my $trigger_sub = sub {
            my ( $self, $value ) = @_;
            if( my $class = delete $self->{"${attr}_attr"}->{class} ) {
                $self->$add_meth($class);
            }
        };
        has "${attr}_attr" => ( is => 'rw', traits => ['Hash'],
            builder => "build_${attr}_attr",
            handles => {
                "has_${attr}_attr" => 'count',
                "get_${attr}_attr" => 'get',
                "set_${attr}_attr" => 'set',
                "delete_${attr}_attr" => 'delete',
                "exists_${attr}_attr" => 'exists',
            },
            trigger => $trigger_sub,
        );
        # create builders fo _attrs
        my $attr_builder = __PACKAGE__ . "::build_${attr}_attr";
        *$attr_builder = subname $attr_builder, sub {{}};
        # create the 'class' slots
        has "${attr}_class" => ( is => 'rw', isa => 'HFH::ArrayRefStr',
            traits => ['Array'],
            coerce => 1,
            builder => "build_${attr}_class",
            handles => {
                "has_${attr}_class" => 'count',
                "_add_${attr}_class" => 'push',
           },
        );
        # create builders for classes
        my $class_builder = __PACKAGE__ . "::build_${attr}_class";
        *$class_builder = subname $class_builder, sub {[]};
        # create wrapper for add_to_ to accept arrayref
        my $add_to_class = __PACKAGE__ . "::add_${attr}_class";
        my $_add_meth = __PACKAGE__ . "::_add_${attr}_class";
        *$add_to_class = subname $add_to_class, sub { shift->$_add_meth((ref $_[0] eq 'ARRAY' ? @{$_[0]} : @_)); }
    }
}

sub attributes { shift->element_attributes(@_) }
sub element_attributes {
    my ( $self, $result ) = @_;
    $result ||= $self->result;
    my $attr = {};
    # handle html5 attributes
    if ($self->form && $self->form->has_flag('is_html5')) {
        $attr->{required} = 'required' if $self->required;
        $attr->{min} = $self->range_start if defined $self->range_start;
        $attr->{max} = $self->range_end if defined $self->range_end;
    }
    # pull in deprecated attributes for backward compatibility
    for my $dep_attr ( 'readonly', 'disabled' ) {
        $attr->{$dep_attr} = $dep_attr if $self->$dep_attr;
    }
    for my $dep_attr ( 'style', 'title', 'tabindex' ) {
        $attr->{$dep_attr} = $self->$dep_attr if defined $self->$dep_attr;
    }
    $attr = {%$attr, %{$self->element_attr}};
    my $class = [@{$self->element_class}];
    push @$class, 'error' if $result->has_errors;
    push @$class, 'warning' if $result->has_warnings;
    push @$class, 'disabled' if $self->disabled;
    $attr->{class} = $class if @$class;
    # call form hook
    my $mod_attr = $self->form->html_attributes($self, 'element', $attr, $result) if $self->form;
    return ref($mod_attr) eq 'HASH' ? $mod_attr : $attr;
}

sub label_attributes {
    my ( $self, $result ) = @_;
    $result ||= $self->result;
    # local copy of label_attr
    my $attr = {%{$self->label_attr}};
    my $class = [@{$self->label_class}];
    $attr->{class} = $class if @$class;
    # call form hook
    my $mod_attr = $self->form->html_attributes($self, 'label', $attr, $result) if $self->form;
    return ref($mod_attr) eq 'HASH' ? $mod_attr : $attr;
}

sub wrapper_attributes {
    my ( $self, $result ) = @_;
    $result ||= $self->result;
    # copy wrapper
    my $attr = {%{$self->wrapper_attr}};
    my $class = [@{$self->wrapper_class}];
    # add 'error' to class
    push @$class, 'error' if ( $result->has_error_results || $result->has_errors );
    push @$class, 'warning' if $result->has_warnings;
    $attr->{class} = $class if @$class;
    # call form hook
    my $mod_attr = $self->form->html_attributes($self, 'wrapper', $attr, $result) if $self->form;
    return ref($mod_attr) eq 'HASH' ? $mod_attr : $attr;
}

sub wrapper_tag {
    my $self = shift;
    return $self->get_tag('wrapper_tag') || 'div';
}

#=====================
# these may be temporary
sub field_filename {
    my $self = shift;
    return 'checkbox_tag.tt' if $self->input_type eq 'checkbox';
    return 'input_tag.tt';
}
sub label_tag {
    my $self = shift;
    return $self->get_tag('label_tag') || 'label';
}
#===================

has 'writeonly'  => ( isa => 'Bool', is => 'rw' );
has 'noupdate'   => ( isa => 'Bool', is => 'rw' );

#==============
sub convert_full_name {
    my $full_name = shift;
    $full_name =~ s/\.\d+\./_/g;
    $full_name =~ s/\./_/g;
    return $full_name;
}
has 'validate_method' => (
     traits => ['Code'],
     is     => 'ro',
     isa    => 'CodeRef',
     lazy   => 1,
     builder => 'build_validate_method',
     handles => { '_validate' => 'execute_method' },
);
has 'set_validate' => ( isa => 'Str', is => 'ro',);
sub build_validate_method {
    my $self = shift;
    my $set_validate = $self->set_validate;
    $set_validate ||= "validate_" . convert_full_name($self->full_name);
    return sub { my $self = shift; $self->form->$set_validate($self); }
        if ( $self->form && $self->form->can($set_validate) );
    return sub { };
}

has 'default_method' => (
     traits => ['Code'],
     is     => 'ro',
     isa    => 'CodeRef',
     writer => '_set_default_method',
     predicate => 'has_default_method',
     handles => { '_default' => 'execute_method' },
);
has 'set_default' => ( isa => 'Str', is => 'ro', writer => '_set_default');
# this is not a "true" builder, because sometimes 'default_method' is not set
sub build_default_method {
    my $self = shift;
    my $set_default = $self->set_default;
    $set_default ||= "default_" . convert_full_name($self->full_name);
    if ( $self->form && $self->form->can($set_default) ) {
        $self->_set_default_method(
            sub { my $self = shift; return $self->form->$set_default($self, $self->form->item); }
        );
    }
}

sub get_default_value {
    my $self = shift;
    if ( $self->has_default_method ) {
        return $self->_default;
    }
    elsif ( defined $self->default ) {
        return $self->default;
    }
    return;
}
{
    # create inflation/deflation methods
    foreach my $type ( 'inflate_default', 'deflate_value', 'inflate', 'deflate' ) {
        has "${type}_method" => ( is => 'ro', traits => ['Code'],
            isa => 'CodeRef',
            writer => "_set_${type}_method",
            predicate => "has_${type}_method",
            handles => {
                $type => 'execute_method',
            },
        );
    }
}

has 'deflation' => (
    is        => 'rw',
    predicate => 'has_deflation',
);
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

    # for backwards compatibility; these will be removed eventually
    my @new;
    push @new, ('element_attr', {@_}->{html_attr} )
        if( exists {@_}->{html_attr} );
    push @new, ('do_label', !{@_}->{no_render_label} )
        if( exists {@_}->{no_render_label} );
    return $class->SUPER::BUILDARGS(@_, @new);
}

sub BUILD {
    my ( $self, $params ) = @_;

    # temporary, for compatibility. move widget_tags to tags
    $self->merge_tags($self->widget_tags) if $self->has_widget_tags;
    # run default method builder
    $self->build_default_method;
    # build validate_method; needs to happen before validation
    # in order to have the "real" repeatable field names, not the instances
    $self->validate_method;
    # merge form widget_name_space
    $self->add_widget_name_space( $self->form->widget_name_space ) if $self->form;
    # handle apply actions
    $self->add_action( $self->trim ) if $self->trim;
    $self->_build_apply_list;
    $self->add_action( @{ $params->{apply} } ) if $params->{apply};
}

# this is the recursive routine that is used
# to initialize field results if there is no initial object and no params
sub _result_from_fields {
    my ( $self, $result ) = @_;

    if ( $self->disabled && $self->has_init_value ) {
        $result->_set_value($self->init_value);
    }
    elsif ( my @values = $self->get_default_value ) {
        if ( $self->has_inflate_default_method ) {
            @values = $self->inflate_default(@values);
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
    elsif ( $self->disabled ) {
        # This really ought to come from _result_from_object, but there's
        # no way to get there from here.
        return $self->_result_from_fields( $result );
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
    my $parent_name;
    # field should always have a parent unless it's a standalone field test
    if ( $field->parent ) {
        $parent_name = $field->parent->full_name;
    }
    return $name unless defined $parent_name && length $parent_name;
    return $parent_name . '.' . $name;
}

sub full_accessor {
    my $field = shift;

    my $parent = $field->parent;
    if( $field->is_contains ) {
        return '' unless $parent;
        return $parent->full_accessor;
    }
    my $accessor = $field->accessor;
    my $parent_accessor;
    if ( $parent ) {
        $parent_accessor = $parent->full_accessor;
    }
    return $accessor unless defined $parent_accessor && length $parent_accessor;
    return $parent_accessor . '.' . $accessor;
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
        die "Error occurred localizing error message for " . $self->label . ". Check brackets. $_";
    };
    return $self->push_errors($out);;
}

sub push_errors {
    my $self = shift;
    $self->_push_errors(@_);
    if ( $self->parent ) {
        $self->parent->propagate_error($self->result);
    }
    return;
}

sub _apply_deflation {
    my ( $self, $value ) = @_;

    if ( $self->has_deflation ) {
        $value = $self->deflation->($value);
    }
    elsif ( $self->has_deflate_method ) {
        $value = $self->deflate($value);
    }
    return $value;
}
sub _can_deflate {
    my $self = shift;
    return $self->has_deflation || $self->has_deflate_method;
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
