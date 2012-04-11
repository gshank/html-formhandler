package HTML::FormHandler;
# ABSTRACT: HTML forms using Moose

use Moose;
extends 'HTML::FormHandler::Base'; # to make some methods overridable by roles
with 'HTML::FormHandler::Model', 'HTML::FormHandler::Fields',
    'HTML::FormHandler::BuildFields',
    'HTML::FormHandler::TraitFor::I18N';
with 'HTML::FormHandler::InitResult';
with 'HTML::FormHandler::Widget::ApplyRole';
with 'HTML::FormHandler::Traits';
with 'HTML::FormHandler::Blocks';

use Carp;
use Class::MOP;
use HTML::FormHandler::Result;
use HTML::FormHandler::Field;
use Try::Tiny;
use MooseX::Types::LoadableClass qw/ LoadableClass /;
use namespace::autoclean;
use HTML::FormHandler::Merge ('merge');
use Sub::Name;
use Data::Clone;

use 5.008;

# always use 5 digits after decimal because of toolchain issues
our $VERSION = '0.40005';

=head1 SYNOPSIS

See the manual at L<HTML::FormHandler::Manual>.

    use HTML::FormHandler; # or a custom form: use MyApp::Form::User;
    my $form = HTML::FormHandler->new( .... );
    $form->process( params => $params );
    my $rendered_form = $form->render;
    if( $form->validated ) {
        # perform validated form actions
    }
    else {
        # perform non-validated actions
    }

Or, if you want to use a form 'result' (which contains only the form
values and error messages) instead:

    use MyApp::Form; # or a generic form: use HTML::FormHandler;
    my $form = MyApp::Form->new( .... );
    my $result = $form->run( params => $params );
    if( $result->validated ) {
        # perform validated form actions
    }
    else {
        # perform non-validated actions
        $result->render;
    }


An example of a custom form class:

    package MyApp::Form::User;

    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    use Moose::Util::TypeConstraints;

    has '+item_class' => ( default => 'User' );

    has_field 'name' => ( type => 'Text' );
    has_field 'age' => ( type => 'PosInteger', apply => [ 'MinimumAge' ] );
    has_field 'birthdate' => ( type => 'DateTime' );
    has_field 'birthdate.month' => ( type => 'Month' );
    has_field 'birthdate.day' => ( type => 'MonthDay' );
    has_field 'birthdate.year' => ( type => 'Year' );
    has_field 'hobbies' => ( type => 'Multiple' );
    has_field 'address' => ( type => 'Text' );
    has_field 'city' => ( type => 'Text' );
    has_field 'state' => ( type => 'Select' );
    has_field 'email' => ( type => 'Email' );

    has '+dependency' => ( default => sub {
          [ ['address', 'city', 'state'], ]
       }
    );

    subtype 'MinimumAge'
       => as 'Int'
       => where { $_ > 13 }
       => message { "You are not old enough to register" };

    no HTML::FormHandler::Moose;
    1;


A dynamic form - one that does not use a custom form class - may be
created using the 'field_list' attribute to set fields:

    my $form = HTML::FormHandler->new(
        name => 'user_form',
        item => $user,
        field_list => [
            'username' => {
                type  => 'Text',
                apply => [ { check => qr/^[0-9a-z]*/,
                   message => 'Contains invalid characters' } ],
            },
            'select_bar' => {
                type     => 'Select',
                options  => \@select_options,
                multiple => 1,
                size     => 4,
            },
        ],
    );

FormHandler does not provide a custom controller for Catalyst because
it isn't necessary. Interfacing to FormHandler is only a couple of
lines of code. See L<HTML::FormHandler::Manual::Catalyst> for more
details, or L<Catalyst::Manual::Tutorial::09_AdvancedCRUD::09_FormHandler>.


=head1 DESCRIPTION

*** Although documentation in this file provides some overview, it is mainly
intended for API documentation. See L<HTML::FormHandler::Manual::Intro>
for an introduction, with links to other documentation.

HTML::FormHandler maintains a clean separation between form construction
and form rendering. It allows you to define your forms and fields in a
number of flexible ways. Although it provides renderers for HTML, you
can define custom renderers for any kind of presentation.

HTML::FormHandler allows you to define form fields and validators. It can
be used for both database and non-database forms, and will
automatically update or create rows in a database. It can be used
to process structured data that doesn't come from an HTML form.

One of its goals is to keep the controller/application program interface as
simple as possible, and to minimize the duplication of code. In most cases,
interfacing your controller to your form is only a few lines of code.

With FormHandler you shouldn't have to spend hours trying to figure out how to make a
simple HTML change that would take one minute by hand. Because you _can_ do it
by hand. Or you can automate HTML generation as much as you want, with
template widgets or pure Perl rendering classes, and stay completely in
control of what, where, and how much is done automatically. You can define
custom renderers and display your rendered forms however you want.

You can split the pieces of your forms up into logical parts and compose
complete forms from FormHandler classes, roles, fields, collections of
validations, transformations and Moose type constraints.
You can write custom methods to process forms, add any attribute you like,
use Moose method modifiers.  FormHandler forms are Perl classes, so there's
a lot of flexibility in what you can do.

HTML::FormHandler provides rendering through roles which are applied to
form and field classes (although there's no reason you couldn't write
a renderer as an external object either).  There are currently two flavors:
all-in-one solutions like L<HTML::FormHandler::Render::Simple> and
L<HTML::FormHandler::Render::Table> that contain methods for rendering
field widget classes, and the L<HTML::FormHandler::Widget> roles, which are
more atomic roles which are automatically applied to fields and form. See
L<HTML::FormHandler::Manual::Rendering> for more details.
(And you can easily use hand-build forms - FormHandler doesn't care.)

The typical application for FormHandler would be in a Catalyst, DBIx::Class,
Template Toolkit web application, but use is not limited to that. FormHandler
can be used in any Perl application.

More Formhandler documentation and a tutorial can be found in the manual
at L<HTML::FormHandler::Manual>.

=head1 ATTRIBUTES and METHODS

=head2 Creating a form with 'new'

The new constructor takes name/value pairs:

    MyForm->new(
        item    => $item,
    );

No attributes are required on new. The form's fields will be built from
the form definitions. If no initial data object or defaults have been provided, the form
will be empty. Most attributes can be set on either 'new' or 'process'.
The common attributes to be passed in to the constructor for a database form
are either item_id and schema or item:

   item_id  - database row primary key
   item     - database row object
   schema   - (for DBIC) the DBIx::Class schema

The following are sometimes passed in, but are also often set
in the form class:

   item_class  - source name of row
   dependency  - (see dependency)
   field_list  - an array of field definitions
   init_object - a hashref or object to provide initial values

Examples of creating a form object with new:

    my $form = MyApp::Form::User->new;

    # database form using a row object
    my $form = MyApp::Form::Member->new( item => $row );

    # a dynamic form (no form class has been defined)
    my $form = HTML::FormHandler::Model::DBIC->new(
        item_id         => $id,
        item_class    => 'User',
        schema          => $schema,
        field_list         => [
                name    => 'Text',
                active  => 'Boolean',
                submit_btn => 'Submit',
        ],
    );

See the model class for more information about the 'item', 'item_id',
'item_class', and schema (for the DBIC model).
L<HTML::FormHandler::Model::DBIC>.

FormHandler forms are handled in two steps: 1) create with 'new',
2) handle with 'process'. FormHandler doesn't
care whether most parameters are set on new or process or update,
but a 'field_list' argument must be passed in on 'new' since the
fields are built at construction time.

If you want to update field attributes on the 'process' call, you can
use an 'update_field_list' or 'defaults' hashref attribute , or subclass
update_fields in your form. The 'update_field_list' hashref can be used
to set any field attribute. The 'defaults' hashref will update only
the 'default' attribute in the field. (There are a lot of ways to
set defaults. See L<HTML::FormHandler::Manual::Defaults>.)

   $form->process( defaults => { foo => 'foo_def', bar => 'bar_def' } );
   $form->process( update_field_list => { foo => { label => 'New Label' } });

Field results are built on the 'new' call, but will then be re-built
on the process call. If you always use 'process' before rendering the form,
accessing fields, etc, you can set the 'no_preload' flag to skip this step.

=head2 Processing the form

=head3 process

Call the 'process' method on your form to perform validation and
update. A database form must have either an item (row object) or
a schema, item_id (row primary key), and item_class (usually set in the form).
A non-database form requires only parameters.

   $form->process( item => $book, params => $c->req->parameters );
   $form->process( item_id => $item_id,
       schema => $schema, params => $c->req->parameters );
   $form->process( params => $c->req->parameters );

This process method returns the 'validated' flag. (C<< $form->validated >>)
If it is a database form and the form validates, the database row
will be updated.

After the form has been processed, you can get a parameter hashref suitable
for using to fill in the form from C<< $form->fif >>.
A hash of inflated values (that would be used to update the database for
a database form) can be retrieved with C<< $form->value >>.

If you don't want to update the database on this process call, you can
set the 'no_update' flag:

   $form->process( item => $book, params => $params, no_update => 1 );

=head3 params

Parameters are passed in when you call 'process'.
HFH gets data to validate and store in the database from the params hash.
If the params hash is empty, no validation is done, so it is not necessary
to check for POST before calling C<< $form->process >>. (Although see
the 'posted' option for complications.)

Params can either be in the form of CGI/HTTP style params:

   {
      user_name => "Joe Smith",
      occupation => "Programmer",
      'addresses.0.street' => "999 Main Street",
      'addresses.0.city' => "Podunk",
      'addresses.0.country' => "UT",
      'addresses.0.address_id' => "1",
      'addresses.1.street' => "333 Valencia Street",
      'addresses.1.city' => "San Francisco",
      'addresses.1.country' => "UT",
      'addresses.1.address_id' => "2",
   }

or as structured data in the form of hashes and lists:

   {
      addresses => [
         {
            city => 'Middle City',
            country => 'GK',
            address_id => 1,
            street => '101 Main St',
         },
         {
            city => 'DownTown',
            country => 'UT',
            address_id => 2,
            street => '99 Elm St',
         },
      ],
      'occupation' => 'management',
      'user_name' => 'jdoe',
   }

CGI style parameters will be converted to hashes and lists for HFH to
operate on.

=head3 posted

Note that FormHandler by default uses empty params as a signal that the
form has not actually been posted, and so will not attempt to validate
a form with empty params. Most of the time this works OK, but if you
have a small form with only the controls that do not return a post
parameter if unselected (checkboxes and select lists), then the form
will not be validated if everything is unselected. For this case you
can either add a hidden field as an 'indicator', or use the 'posted' flag:

   $form->process( posted => ($c->req->method eq 'POST'), params => ... );

The 'posted' flag also works to prevent validation from being performed
if there are extra params in the params hash and it is not a 'POST' request.

=head2 Getting data out

=head3 fif  (fill in form)

If you don't use FormHandler rendering and want to fill your form values in
using some other method (such as with HTML::FillInForm or using a template)
this returns a hash of values that are equivalent to params which you may
use to fill in your form.

The fif value for a 'title' field in a TT form:

   [% form.fif.title %]

Or you can use the 'fif' method on individual fields:

   [% form.field('title').fif %]

If you use FormHandler to render your forms or field you probably won't use
these methods.

=head3 value

Returns a hashref of all field values. Useful for non-database forms, or if
you want to update the database yourself. The 'fif' method returns
a hashref with the field names for the keys and the field's 'fif' for the
values; 'value' returns a hashref with the field accessors for the keys, and the
field's 'value' (possibly inflated) for the the values.

Forms containing arrays to be processed with L<HTML::FormHandler::Field::Repeatable>
will have parameters with dots and numbers, like 'addresses.0.city', while the
values hash will transform the fields with numbers to arrays.

=head2 Accessing and setting up fields

Fields are declared with a number of attributes which are defined in
L<HTML::FormHandler::Field>. If you want additional attributes you can
define your own field classes (or apply a role to a field class - see
L<HTML::FormHandler::Manual::Cookbook>). The field 'type' (used in field
definitions) is the short class name of the field class, used when
searching the 'field_name_space' for the field class.

=head3 has_field

The most common way of declaring fields is the 'has_field' syntax.
Using the 'has_field' syntax sugar requires C< use HTML::FormHandler::Moose; >
or C< use HTML::FormHandler::Moose::Role; > in a role.
See L<HTML::FormHandler::Manual::Intro>

   use HTML::FormHandler::Moose;
   has_field 'field_name' => ( type => 'FieldClass', .... );

=head3 field_list

A 'field_list' is an array of field definitions which can be used as an
alternative to 'has_field' in small, dynamic forms to create fields.

    field_list => [
       field_one => {
          type => 'Text',
          required => 1
       },
       field_two => 'Text,
    ]

The field_list array takes elements which are either a field_name key
pointing to a 'type' string or a field_name key pointing to a
hashref of field attributes. You can also provide an array of
hashref elements with the name as an additional attribute.
The field list can be set inside a form class, when you want to
add fields to the form depending on some other state, although
you can also create all the fields and set some of them inactive.

   sub field_list {
      my $self = shift;
      my $fields = $self->schema->resultset('SomeTable')->
                          search({user_id => $self->user_id, .... });
      my @field_list;
      while ( my $field = $fields->next )
      {
         < create field list >
      }
      return \@field_list;
   }

=head3 update_field_list

Used to dynamically set particular field attributes on the 'process' (or
'run') call. (Will not create fields.)

    $form->process( update_field_list => {
       foo_date => { format => '%m/%e/%Y', date_start => '10-01-01' } },
       params => $params );

The 'update_field_list' is processed by the 'update_fields' form method,
which can also be used in a form to do specific field updates:

    sub update_fields {
        my $self = shift;
        $self->field('foo')->temp( 'foo_temp' );
        $self->field('bar')->default( 'foo_value' );
        $self->next::method();
    }

(Note that you although you can set a field's 'default', you can't set a
field's 'value' directly here, since it will
be overwritten by the validation process. Set the value in a field
validation method.)

=head3 update_subfields

Yet another way to provide settings for the field, except this one is intended for
use in roles and compound fields, and is only executed when the form is
initially built. It takes the same field name keys as 'update_field_list', plus
'all' and 'by_flag'.

    sub build_update_subfields {{
        all => { tags => { wrapper_tag => 'p' } },
        foo => { element_class => 'blue' },
    }}

The 'all' hash key will apply updates to all fields (conflicting attributes
in a field definition take precedence.)

The 'by_flag' hash key will apply updates to fields with a particular flag.
The currently supported subkeys are 'compound', 'contains', and 'repeatable'.
(For repeatable instances, in addition to 'contains' you can also use the
'repeatable' key and the 'init_contains' attribute.)
This is useful for turning on the rendering
wrappers for compounds and repeatables, which are off by default. (The
repeatable instances are wrapped by default.)

    sub build_update_subfields {{
        by_flag => { compound => { do_wrapper => 1 } },
        by_type => { Select => { element_class => ['sel_elem'] } },
    }}

The 'by_type' hash key will provide values to all fields of a particular
type.


=head3 defaults

This is a more specialized version of the 'update_field_list'. It can be
used to provide 'default' settings for fields, in a shorthand way (you don't
have to say 'default' for every field).

   $form->process( defaults => { foo => 'this_foo', bar => 'this_bar' }, ... );

=head3 active/inactive

A field can be marked 'inactive' and set to active at new or process time;
Then the field name can be specified in the 'active' array, either on 'new',
or on 'process':

   has_field 'foo' => ( type => 'Text', inactive => 1 );
   ...
   my $form = MyApp::Form->new( active => ['foo'] );
   ...
   $form->process( active => ['foo'] );

Or a field can be a normal active field and set to inactive at new or process
time:

   has_field 'bar';
   ...
   my $form = MyApp::Form->new( inactive => ['foo'] );
   ...
   $form->process( inactive => ['foo'] );

Fields specified as active/inactive on new will have the form's inactive/active
arrayref cleared and the the field's inactive flag set appropriately, so the
that state will be effective for the life of the form object. Fields specified as
active/inactive on 'process' will have the field's '_active' flag set for the life
of the request (the _active flag will be cleared when the form is cleared).

The 'sorted_fields' method returns only active fields, sorted according to the
'order' attribute. The 'fields' method returns all fields.

   foreach my $field ( $self->sorted_fields ) { ... }

You can test whether a field is active by using the field 'is_active' and 'is_inactive'
methods.

=head3 field_name_space

Use to look for field during form construction. If a field is not found
with the field_name_space (or HTML::FormHandler/HTML::FormHandlerX),
the 'type' must start with a '+' and be the complete package name.

=head3 fields

The array of fields, objects of L<HTML::FormHandler::Field> or its subclasses.
A compound field will itself have an array of fields,
so this is a tree structure.

=head3 sorted_fields

Returns those fields from the fields array which are currently active. This
is the method that returns the fields that are looped through when rendering.

=head3 field($name)

This is the method that is usually called to access a field:

    my $title = $form->field('title')->value;
    [% f = form.field('title') %]

    my $city = $form->field('addresses.0.city')->value;

Pass a second true value to die on errors.

=head2 Constraints and validation

Most validation is performed on a per-field basis, and there are a number
of different places in which validation can be performed.

See also L<HTML::FormHandler::Manual::Validation>.

=head3 Form class validation for individual fields

You can define a method in your form class to perform validation on a field.
This method is the equivalent of the field class validate method except it is
in the form class, so you might use this
validation method if you don't want to create a field subclass.

It has access to the form ($self) and the field.
This method is called after the field class 'validate' method, and is not
called if the value for the field is empty ('', undef). (If you want an
error message when the field is empty, use the 'required' flag and message
or the form 'validate' method.)
The name of this method can be set with 'set_validate' on the field. The
default is 'validate_' plus the field name:

   sub validate_testfield { my ( $self, $field ) = @_; ... }

If the field name has dots they should be replaced with underscores.

Note that you also provide a coderef which will be a method on the field:

   has_field 'foo' => ( validate_method => \&validate_foo );

=head3 validate

This is a form method that is useful for cross checking values after they have
been saved as their final validated value, and for performing more complex
dependency validation. It is called after all other field validation is done,
and whether or not validation has succeeded, so it has access to the
post-validation values of all the fields.

This is the best place to do validation checks that depend on the values of
more than one field.

=head2 Accessing errors

Also see L<HTML::FormHandler::Manual::Errors>.

Set an error in a field with C<< $field->add_error('some error string'); >>.
Set a form error not tied to a specific field with
C<< $self->add_form_error('another error string'); >>.
The 'add_error' and 'add_form_error' methods call localization. If you
want to skip localization for a particular error, you can use 'push_errors'
or 'push_form_errors' instead.

  has_errors - returns true or false
  error_fields - returns list of fields with errors
  errors - returns array of error messages for the entire form
  num_errors - number of errors in form

Each field has an array of error messages. (errors, has_errors, num_errors,
clear_errors)

  $form->field('title')->errors;

Compound fields also have an array of error_fields.

=head2 Clear form state

The clear method is called at the beginning of 'process' if the form
object is reused, such as when it is persistent in a Moose attribute,
or in tests.  If you add other attributes to your form that are set on
each request, you may need to clear those yourself.

If you do not call the form's 'process' method on a persistent form,
such as in a REST controller's non-POST method or if you only call
process when the form is posted, you will also need to call C<< $form->clear >>.

The 'run' method which returns a result object always performs 'clear', to
keep the form object clean.

=head2 Miscellaneous attributes

=head3 name

The form's name.  Useful for multiple forms. Used for the form element 'id'.
When 'html_prefix' is set it is used to construct the field 'id'
and 'name'.  The default is "form" + a one to three digit random number.
Because the HTML standards have flip-flopped on whether the HTML
form element can contain a 'name' attribute, please set a name attribute
using 'form_element_attr'.

=head3 init_object

An 'init_object' may be used instead of the 'item' to pre-populate the values
in the form. This can be useful when populating a form from default values
stored in a similar but different object than the one the form is creating.
The 'init_object' should be either a hash or the same type of object that
the model uses (a DBIx::Class row for the DBIC model). It can be set in a
variety of ways:

   my $form = MyApp::Form->new( init_object => { .... } );
   $form->process( init_object => {...}, ... );
   has '+init_object' => ( default => sub { { .... } } );
   sub init_object { my $self = shift; .... }

The method version is useful if the organization of data in your form does
not map to an existing or database object in an automatic way, and you need
to create a different type of object for initialization. (You might also
want to do 'update_model' yourself.)

Also see the 'use_init_obj_over_item' flag, if you want to provide both an
item and an init_object, and use the values from the init_object.

=head3 ctx

Place to store application context for your use in your form's methods.

=head3 language_handle

See 'language_handle' and '_build_language_handle' in
L<HTML::FormHandler::TraitFor::I18N>.

=head3 dependency

Arrayref of arrayrefs of fields. If one of a group of fields has a
value, then all of the group are set to 'required'.

  has '+dependency' => ( default => sub { [
     ['street', 'city', 'state', 'zip' ],] }
  );

=head2 Flags

=head3 validated, is_valid

Flag that indicates if form has been validated. You might want to use
this flag if you're doing something in between process and returning,
such as setting a stash key. ('is_valid' is a synonym for this flag)

   $form->process( ... );
   $c->stash->{...} = ...;
   return unless $form->validated;

=head3 ran_validation

Flag to indicate that validation has been run. This flag will be
false when the form is initially loaded and displayed, since
validation is not run until FormHandler has params to validate.

=head3 verbose, dump, peek

Flag to dump diagnostic information. See 'dump_fields' and
'dump_validated'. 'Peek' can be useful in diagnosing bugs.
It will dump a brief listing of the fields and results.

   $form->process( ... );
   $form->peek;

=head3 html_prefix

Flag to indicate that the form name is used as a prefix for fields
in an HTML form. Useful for multiple forms
on the same HTML page. The prefix is stripped off of the fields
before creating the internal field name, and added back in when
returning a parameter hash from the 'fif' method. For example,
the field name in the HTML form could be "book.borrower", and
the field name in the FormHandler form (and the database column)
would be just "borrower".

   has '+name' => ( default => 'book' );
   has '+html_prefix' => ( default => 1 );

Also see the Field attribute "html_name", a convenience function which
will return the form name + "." + field full_name

=head3 is_html5

Flag to indicate the fields will render using specialized attributes for html5.
Set to 0 by default.

=head3 use_defaults_over_obj

The 'normal' precedence is that if there is an accessor in the item/init_object
that value is used and not the 'default'. This flag makes the defaults of higher
precedence. Mainly useful if providing an empty row on create.

=head3 use_init_obj_over_item

If you are providing both an item and an init_object, and want the init_object
to be used for defaults instead of the item.

=head2 For use in HTML

   form_element_attr - hashref for setting arbitrary HTML attributes
      set in form with: sub build_form_element_attr {...}
   form_element_class - arrayref for setting form tag class
   form_wrapper_attr - hashref for form wrapper element attributes
      set in form with: sub build_form_wrapper_attr {...}
   form_wrapper_class - arrayref for setting wrapper class
   do_form_wrapper - flag to wrap the form
   http_method - For storing 'post' or 'get'
   action - Store the form 'action' on submission. No default value.
   uuid - generates a string containing an HTML field with UUID
   form_tags - hashref of tags for use in rendering code
   widget_tags - rendering tags to be transferred to fields

Discouraged (use form_element_attr instead):

   css_class - adds a 'class' attribute to the form tag
   style - adds a 'style' attribute to the form tag
   enctype - Request enctype

Note that the form tag contains an 'id' attribute which is set to the
form name. The standards have been flip-flopping over whether a 'name'
attribute is valid. It can be set with 'form_element_attr'.

The rendering of the HTML attributes is done using the 'process_attrs'
function and the 'element_attributes' or 'wrapper_attributes' method,
which adds other attributes in for backward compatibility, and calls
the 'html_attributes' hook.

For HTML attributes, there is a form method hook, 'html_attributes',
which can be used to customize/modify/localize form & field HTML attributes.
Types: element, wrapper, label, form_element, form_wrapper, checkbox_label

   sub html_attributes {
       my ( $self, $field, $type, $attr ) = @_;
       $attr->{class} = 'label' if $type eq 'label';
       $attr->{placeholder} = $self->_localize($attr->{placeholder})
           if exists $attr->{placeholder};
       return $attr;
   }

Also see the documentation in L<HTML::FormHandler::Field> and in
L<HTML::FormHandler::Manual::Rendering>.

=cut

# for consistency in api with field nodes
sub form { shift }
sub has_form { 1 }

# Moose attributes
has 'name' => (
    isa     => 'Str',
    is      => 'rw',
    default => sub { return 'form' . int( rand 1000 ) }
);
has 'parent' => ( is => 'rw' );
has 'result' => (
    isa       => 'HTML::FormHandler::Result',
    is        => 'ro',
    writer    => '_set_result',
    clearer   => 'clear_result',
    lazy      => 1,
    builder   => 'build_result',
    predicate => 'has_result',
    handles   => [
        'input',      '_set_input', '_clear_input', 'has_input',
        'value',      '_set_value', '_clear_value', 'has_value',
        'add_result', 'results',    'validated',    'ran_validation',
        'is_valid',
        'form_errors', 'all_form_errors', 'push_form_errors', 'clear_form_errors',
        'has_form_errors', 'num_form_errors',
    ],
);

sub build_result {
    my $self = shift;
    my $result_class = 'HTML::FormHandler::Result';
    if ( $self->widget_form ) {
        my $role = $self->get_widget_role( $self->widget_form, 'Form' );
        $result_class = $result_class->with_traits( $role );
    }
    my $result = $result_class->new( name => $self->name, form => $self );
    return $result;
}

has 'index' => (
    is => 'ro', isa => 'HashRef[HTML::FormHandler::Field]', traits => ['Hash'],
    default => sub {{}},
    handles => {
        add_to_index => 'set',
        field_from_index => 'get',
        field_in_index => 'exists',
    }
);

has 'field_traits' => ( is => 'ro', traits => ['Array'], isa => 'ArrayRef',
    default => sub {[]}, handles => { 'has_field_traits' => 'count' } );
has 'widget_name_space' => (
    is => 'ro',
    isa => 'HFH::ArrayRefStr',
    traits => ['Array'],
    default => sub {[]},
    coerce => 1,
    handles => {
        add_widget_name_space => 'push',
    },
);
# it only really makes sense to set these before widget_form is applied in BUILD
has 'widget_form'       => ( is => 'ro', isa => 'Str', default => 'Simple', writer => 'set_widget_form' );
has 'widget_wrapper'    => ( is => 'ro', isa => 'Str', default => 'Simple', writer => 'set_widget_wrapper' );
has 'do_form_wrapper' => ( is => 'rw', builder => 'build_do_form_wrapper' );
sub build_do_form_wrapper { 0 }
has 'no_widgets'        => ( is => 'ro', isa => 'Bool' );
has 'no_preload'        => ( is => 'ro', isa => 'Bool' );
has 'no_update'         => ( is => 'rw', isa => 'Bool', clearer => 'clear_no_update' );
has 'active' => (
    is => 'rw',
    traits => ['Array'],
    isa => 'ArrayRef[Str]',
    default => sub {[]},
    handles => {
        add_active => 'push',
        has_active => 'count',
        clear_active => 'clear',
    }
);
has 'inactive' => (
    is => 'rw',
    traits => ['Array'],
    isa => 'ArrayRef[Str]',
    default => sub {[]},
    handles => {
        add_inactive => 'push',
        has_inactive => 'count',
        clear_inactive => 'clear',
    }
);


# object with which to initialize
has 'init_object'         => ( is => 'rw', clearer => 'clear_init_object' );
has 'update_field_list'   => ( is => 'rw',
    isa => 'HashRef',
    default => sub {{}},
    traits => ['Hash'],
    handles => {
        clear_update_field_list => 'clear',
        has_update_field_list => 'count',
        set_update_field_list => 'set',
    },
);
has 'defaults' => ( is => 'rw', isa => 'HashRef', default => sub {{}}, traits => ['Hash'],
    handles => { has_defaults => 'count', clear_defaults => 'clear' },
);
has 'use_defaults_over_obj' => ( is => 'rw', isa => 'Bool', clearer => 'clear_use_defaults_over_obj' );
has 'use_init_obj_over_item' => ( is => 'rw', isa => 'Bool', clearer => 'clear_use_init_obj_over_item' );
has 'reload_after_update' => ( is => 'rw', isa     => 'Bool' );
# flags
has [ 'verbose', 'processed', 'did_init_obj' ] => ( isa => 'Bool', is => 'rw' );
has 'user_data' => ( isa => 'HashRef', is => 'rw' );
has 'ctx' => ( is => 'rw', weak_ref => 1, clearer => 'clear_ctx' );
has 'html_prefix'   => ( isa => 'Bool', is  => 'ro' );
has 'active_column' => ( isa => 'Str',  is  => 'ro' );
has 'http_method'   => ( isa => 'Str',  is  => 'ro', default => 'post' );
has 'enctype'       => ( is  => 'rw',   isa => 'Str' );
has 'error_message' => ( is => 'rw', predicate => 'has_error_message', clearer => 'clear_error_message' );
has 'success_message' => ( is => 'rw', predicate => 'has_success_message', clearer => 'clear_success_message' );
# deprecated
has 'css_class' =>     ( isa => 'Str',  is => 'ro' );
has 'style'     =>     ( isa => 'Str',  is => 'rw' );

has 'is_html5'  => ( isa => 'Bool', is => 'ro', default => 0 );
# deprecated. use form_element_attr instead
has 'html_attr' => ( is => 'rw', traits => ['Hash'],
   default => sub { {} }, handles => { has_html_attr => 'count',
   set_html_attr => 'set', delete_html_attr => 'delete' },
   trigger => \&_html_attr_set,
);
sub _html_attr_set {
    my ( $self, $value ) = @_;
    my $class = delete $value->{class};
    $self->form_element_attr($value);
    $self->add_form_element_class if $class;
}

{
    # create the attributes and methods for
    # form_element_attr, build_form_element_attr, form_element_class,
    # form_wrapper_attr, build_form_wrapper_atrr, form_wrapper_class
    no strict 'refs';
    foreach my $attr ('form_wrapper', 'form_element' ) {
        my $add_meth = "add_${attr}_class";
        has "${attr}_attr" => ( is => 'rw', traits => ['Hash'],
            builder => "build_${attr}_attr",
            handles => {
                "has_${attr}_attr" => 'count',
                "get_${attr}_attr" => 'get',
                "set_${attr}_attr" => 'set',
                "delete_${attr}_attr" => 'delete',
                "exists_${attr}_attr" => 'exists',
            },
        );
        # create builders for _attr
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
        # create add method that takes an arrayref
        *$add_to_class = subname $add_to_class, sub { shift->$_add_meth((ref $_[0] eq 'ARRAY' ? @{$_[0]} : @_)); }
    }
}

sub attributes { shift->form_element_attributes(@_) }
sub form_element_attributes {
    my ( $self, $result ) = @_;
    $result ||= $self->result;
    my $attr = {};
    $attr->{id} = $self->name;
    $attr->{action} = $self->action if $self->action;
    $attr->{method} = $self->http_method if $self->http_method;
    $attr->{enctype} = $self->enctype if $self->enctype;
    $attr->{class} = $self->css_class if $self->css_class;
    $attr->{style} = $self->style if $self->style;
    $attr = {%$attr, %{$self->form_element_attr}};
    my $class = [@{$self->form_element_class}];
    $attr->{class} = $class if @$class;
    my $mod_attr = $self->html_attributes($self, 'form_element', $attr);
    return ref $mod_attr eq 'HASH' ? $mod_attr : $attr;
}
sub form_wrapper_attributes {
    my ( $self, $result ) = @_;
    $result ||= $self->result;
    my $attr = {%{$self->form_wrapper_attr}};
    my $class = [@{$self->form_wrapper_class}];
    $attr->{class} = $class if @$class;
    my $mod_attr = $self->html_attributes($self, 'form_wrapper', $attr);
    return ref $mod_attr eq 'HASH' ? $mod_attr : $attr;
}

sub html_attributes {
    my ( $self, $obj, $type, $attrs, $result ) = @_;
    # deprecated 'field_html_attributes'; name changed, remove eventually
    if( $self->can('field_html_attributes') ) {
        $attrs = $self->field_html_attributes( $obj, $type, $attrs, $result );
    }
    return $attrs;
}

sub has_flag {
    my ( $self, $flag_name ) = @_;
    return unless $self->can($flag_name);
    return $self->$flag_name;
}

# used to transfer tags to fields from form
has 'widget_tags' => (
    isa => 'HashRef',
    traits => ['Hash'],
    is => 'rw',
    default => sub {{}},
    handles => {
        has_widget_tags => 'count'
    }
);
has 'form_tags'         => (
    traits => ['Hash'],
    isa => 'HashRef',
    is => 'ro',
    builder => 'build_form_tags',
    handles => {
      _get_tag => 'get',
      set_tag => 'set',
      tag_exists => 'exists',
      has_tag => 'exists',
    },
);
sub build_form_tags {{}}
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

has 'action' => ( is => 'rw' );
has 'posted' => ( is => 'rw', isa => 'Bool', clearer => 'clear_posted', predicate => 'has_posted' );
has 'params' => (
    traits     => ['Hash'],
    isa        => 'HashRef',
    is         => 'rw',
    default    => sub { {} },
    trigger    => sub { shift->_munge_params(@_) },
    handles   => {
        set_param => 'set',
        get_param => 'get',
        clear_params => 'clear',
        has_params => 'count',
    },
);
sub submitted { shift->has_params }
has 'dependency' => ( isa => 'ArrayRef', is => 'rw' );
has '_required' => (
    traits     => ['Array'],
    isa        => 'ArrayRef[HTML::FormHandler::Field]',
    is         => 'rw',
    default    => sub { [] },
    handles   => {
        clear_required => 'clear',
        add_required => 'push',
    }
);

# these messages could apply to either fields or form
has 'messages' => ( is => 'rw',
    isa => 'HashRef',
    traits => ['Hash'],
    builder => 'build_messages',
    handles => {
        '_get_form_message' => 'get',
        '_has_form_message' => 'exists',
        'set_message' => 'set',
    },
);
sub build_messages { {} }

my $class_messages = {};
sub get_class_messages  {
    return $class_messages;
}

sub get_message {
    my ( $self, $msg ) = @_;
    return $self->_get_form_message($msg) if $self->_has_form_message($msg);
    return $self->get_class_messages->{$msg};
}
sub all_messages {
    my $self = shift;
    return { %{$self->get_class_messages}, %{$self->messages} };
}

has 'params_class' => (
    is      => 'ro',
    isa     => LoadableClass,
    coerce  => 1,
    default => 'HTML::FormHandler::Params',
);

has 'params_args' => ( is => 'ro', isa => 'ArrayRef' );

sub BUILDARGS {
    my $class = shift;

    if ( scalar @_ == 1 && ref( $_[0]) ne 'HASH' ) {
        my $arg = $_[0];
        return blessed($arg) ? { item => $arg } : { item_id => $arg };
    }
    return $class->SUPER::BUILDARGS(@_);
}

sub BUILD {
    my $self = shift;

    $self->before_build; # hook to allow customizing forms
    # HTML::FormHandler::Widget::Form::Simple is applied in Base
    $self->apply_widget_role( $self, $self->widget_form, 'Form' )
        unless (  $self->no_widgets || $self->widget_form eq 'Simple' );
    $self->_build_fields;    # create the form fields (BuildFields.pm)
    $self->build_active if $self->has_active || $self->has_inactive || $self->has_flag('is_wizard');
    $self->after_build; # hook for customizing
    return if defined $self->item_id && !$self->item;
    # Load values from object (if any)
    # Would rather not load results at all here, but skipping it breaks
    # existing apps that perform certain actions between 'new' and 'process'.
    # Added fudge flag no_preload to enable skipping.
    # A well-behaved program that always does ->process shouldn't need this preloading.
    unless( $self->no_preload ) {
        if ( my $init_object = $self->use_init_obj_over_item ?
            ($self->init_object || $self->item) : ( $self->item || $self->init_object ) ) {
            $self->_result_from_object( $self->result, $init_object );
        }
        else {
            $self->_result_from_fields( $self->result );
        }
    }
    $self->dump_fields if $self->verbose;
    return;
}
sub before_build {}
sub after_build {}

sub process {
    my $self = shift;

    warn "HFH: process ", $self->name, "\n" if $self->verbose;
    $self->clear if $self->processed;
    $self->setup_form(@_);
    $self->validate_form      if $self->posted;
    $self->update_model       if ( $self->validated && !$self->no_update );
    $self->after_update_model if $self->validated;
    $self->dump_fields        if $self->verbose;
    $self->processed(1);
    return $self->validated;
}

sub run {
    my $self = shift;
    $self->setup_form(@_);
    $self->validate_form      if $self->posted;
    $self->update_model       if ( $self->validated && !$self->no_update );;
    $self->after_update_model if $self->validated;
    my $result = $self->result;
    $self->clear;
    return $result;
}

sub db_validate {
    my $self = shift;
    my $fif  = $self->fif;
    $self->process($fif);
    return $self->validated;
}

sub clear {
    my $self = shift;
    $self->clear_data;
    $self->clear_params;
    $self->clear_posted;
    $self->clear_ctx;
    $self->processed(0);
    $self->did_init_obj(0);
    $self->clear_result;
    $self->clear_use_defaults_over_obj;
    $self->clear_use_init_obj_over_item;
    $self->clear_no_update;
}

sub values { shift->value }

# deprecated?
sub error_field_names {
    my $self         = shift;
    my @error_fields = $self->error_fields;
    return map { $_->name } @error_fields;
}

sub errors {
    my $self         = shift;
    my @error_fields = $self->error_fields;
    my @errors = $self->all_form_errors;
    push @errors,  map { $_->all_errors } @error_fields;
    return @errors;
}

sub uuid {
    my $form = shift;
    require Data::UUID;
    my $uuid = Data::UUID->new->create_str;
    return qq[<input type="hidden" name="form_uuid" value="$uuid">];
}

sub validate_form {
    my $self   = shift;
    my $params = $self->params;
    $self->_set_dependency;    # set required dependencies
    $self->_fields_validate;
    $self->validate;           # empty method for users
    $self->validate_model;     # model specific validation
    $self->fields_set_value;
    $self->_clear_dependency;
    $self->clear_posted;
    $self->get_error_fields;
    $self->ran_validation(1);
    $self->dump_validated if $self->verbose;
    return $self->validated;
}

sub validate { 1 }

sub has_errors {
    my $self = shift;
    return $self->has_error_fields || $self->has_form_errors;
}
sub num_errors {
    my $self = shift;
    return $self->num_error_fields + $self->num_form_errors;
}

sub after_update_model {
    my $self = shift;
    $self->_result_from_object( $self->result, $self->item )
        if ( $self->reload_after_update && $self->item );
}

sub setup_form {
    my ( $self, @args ) = @_;
    if ( @args == 1 ) {
        $self->params( $args[0] );
    }
    elsif ( @args > 1 ) {
        my $hashref = {@args};
        while ( my ( $key, $value ) = each %{$hashref} ) {
            confess "invalid attribute '$key' passed to setup_form"
                unless $self->can($key);
            $self->$key($value);
        }
    }
    if ( $self->item_id && !$self->item ) {
        $self->item( $self->build_item );
    }
    $self->clear_result;
    $self->set_active;
    $self->update_fields;
    # initialization of Repeatable fields and Select options
    # will be done in _result_from_object when there's an initial object
    # in _result_from_input when there are params
    # and by _result_from_fields for empty forms
    $self->posted(1) if ( $self->has_params && !$self->has_posted );
    if ( !$self->did_init_obj ) {
        if ( my $init_object = $self->use_init_obj_over_item ?
            ($self->init_object || $self->item) : ( $self->item || $self->init_object ) ) {
            $self->_result_from_object( $self->result, $init_object );
        }
        elsif ( !$self->posted ) {
            # no initial object. empty form form must be initialized
            $self->_result_from_fields( $self->result );
        }
    }
    # if params exist and if posted flag is either not set or set to true
    my $params = clone( $self->params );
    if ( $self->posted ) {
        $self->clear_result;
        $self->_result_from_input( $self->result, $params, 1 );
    }

}

# if active => [...] is set at process time, set 'active' flag
sub set_active {
    my $self = shift;
    if( $self->has_active ) {
        foreach my $fname (@{$self->active}) {
            my $field = $self->field($fname);
            if ( $field ) {
                $field->_active(1);
            }
            else {
                warn "field $fname not found to set active";
            }
        }
        $self->clear_active;
    }
    if( $self->has_inactive ) {
        foreach my $fname (@{$self->inactive}) {
            my $field = $self->field($fname);
            if ( $field ) {
                $field->_active(0);
            }
            else {
                warn "field $fname not found to set inactive";
            }
        }
        $self->clear_inactive;
    }
}

# if active => [...] is set at build time, remove 'inactive' flags
sub build_active {
    my $self = shift;
    if( $self->has_active ) {
        foreach my $fname (@{$self->active}) {
            my $field = $self->field($fname);
            if( $field ) {
                $field->clear_inactive;
            }
            else {
                warn "field $fname not found to set active";
            }
        }
        $self->clear_active;
    }
    if( $self->has_inactive ) {
        foreach my $fname (@{$self->inactive}) {
            my $field = $self->field($fname);
            if( $field ) {
                $field->inactive(1);
            }
            else {
                warn "field $fname not found to set inactive";
            }
        }
        $self->clear_inactive;
    }
}

sub fif { shift->fields_fif(@_) }

# this is subclassed by the model, which may
# do a lot more than this
sub init_value {
    my ( $self, $field, $value ) = @_;
    $field->init_value($value);
    $field->_set_value($value);
}

sub _set_dependency {
    my $self = shift;

    my $depends = $self->dependency || return;
    my $params = $self->params;
    for my $group (@$depends) {
        next if @$group < 2;
        # process a group of fields
        for my $name (@$group) {
            # is there a value?
            my $value = $params->{$name};
            next unless defined $value;
            # The exception is a boolean can be zero which we count as not set.
            # This is to allow requiring a field when a boolean is true.
            my $field = $self->field($name);
            next if $self->field($name)->type eq 'Boolean' && $value == 0;
            next unless HTML::FormHandler::Field::has_some_value($value);
            # one field was found non-blank, so set all to required
            for (@$group) {
                my $field = $self->field($_);
                next unless $field && !$field->required;
                $self->add_required($field);    # save for clearing later.
                $field->required(1);
            }
            last;
        }
    }
}

sub _clear_dependency {
    my $self = shift;

    $_->required(0) for @{$self->_required};
    $self->clear_required;
}

sub peek {
    my $self = shift;
    my $string = "Form " . $self->name . "\n";
    my $indent = '  ';
    foreach my $field ( $self->sorted_fields ) {
        $string .= $field->peek( $indent );
    }
    return $string;
}

sub _munge_params {
    my ( $self, $params, $attr ) = @_;
    my $_fix_params = $self->params_class->new( @{ $self->params_args || [] } );
    my $new_params = $_fix_params->expand_hash($params);
    if ( $self->html_prefix ) {
        $new_params = $new_params->{ $self->name };
    }
    $new_params = {} if !defined $new_params;
    $self->{params} = $new_params;
}

after 'get_error_fields' => sub {
   my $self = shift;
   foreach my $err_res (@{$self->result->error_results}) {
       $self->result->push_errors($err_res->all_errors);
   }
};

sub add_form_error {
    my ( $self, @message ) = @_;

    unless ( defined $message[0] ) {
        @message = ('form is invalid');
    }
    my $out;
    try {
        $out = $self->_localize(@message);
    }
    catch {
        die "Error occurred localizing error message for " . $self->name . ".  $_";
    };
    $self->push_form_errors($out);
    return;
}

sub get_default_value { }
sub _can_deflate { }

sub update_fields {
    my $self = shift;
    if( $self->has_update_field_list ) {
        my $updates = $self->update_field_list;
        foreach my $field_name ( keys %{$updates} ) {
            $self->update_field($field_name, $updates->{$field_name} );
        }
        $self->clear_update_field_list;
    }
    if( $self->has_defaults ) {
        my $defaults = $self->defaults;
        foreach my $field_name ( keys %{$defaults} ) {
            $self->update_field($field_name, { default => $defaults->{$field_name} } );
        }
        $self->clear_defaults;
    }
}

sub update_field {
    my ( $self, $field_name, $updates ) = @_;

    my $field = $self->field($field_name);
    unless( $field ) {
        die "Field $field_name is not found and cannot be updated by update_fields";
    }
    while ( my ( $attr_name, $attr_value ) = each %{$updates} ) {
        confess "invalid attribute '$attr_name' passed to update_field"
            unless $field->can($attr_name);
        if( $attr_name eq 'tags' ) {
            $field->set_tag(%$attr_value);
        }
        else {
            $field->$attr_name($attr_value);
        }
    }
}

=head1 SUPPORT

IRC:

  Join #formhandler on irc.perl.org

Mailing list:

  http://groups.google.com/group/formhandler

Code repository:

  http://github.com/gshank/html-formhandler/tree/master

Bug tracker:

  https://rt.cpan.org/Dist/Display.html?Name=HTML-FormHandler

=head1 SEE ALSO

L<HTML::FormHandler::Manual>

L<HTML::FormHandler::Manual::Tutorial>

L<HTML::FormHandler::Manual::Intro>

L<HTML::FormHandler::Manual::Templates>

L<HTML::FormHandler::Manual::Cookbook>

L<HTML::FormHandler::Manual::Rendering>

L<HTML::FormHandler::Manual::Reference>

L<HTML::FormHandler::Field>

L<HTML::FormHandler::Model::DBIC>

L<HTML::FormHandler::Render::Simple>

L<HTML::FormHandler::Render::Table>

L<HTML::FormHandler::Moose>


=head1 CONTRIBUTORS

gshank: Gerda Shank E<lt>gshank@cpan.orgE<gt>

zby: Zbigniew Lukasiak E<lt>zby@cpan.orgE<gt>

t0m: Tomas Doran E<lt>bobtfish@bobtfish.netE<gt>

augensalat: Bernhard Graf E<lt>augensalat@gmail.comE<gt>

cubuanic: Oleg Kostyuk E<lt>cub.uanic@gmail.comE<gt>

rafl: Florian Ragwitz E<lt>rafl@debian.orgE<gt>

mazpe: Lester Ariel Mesa

dew: Dan Thomas

koki: Klaus Ita

jnapiorkowski: John Napiorkowski

lestrrat: Daisuke Maki

hobbs: Andrew Rodland

Andy Clayton

boghead: Bryan Beeley

Csaba Hetenyi

Eisuke Oishi

Lian Wan Situ

Murray

Nick Logan

Vladimir Timofeev

diegok: Diego Kuperman

ijw: Ian Wells

amiri: Amiri Barksdale

ozum: Ozum Eldogan

Initially based on the source code of L<Form::Processor> by Bill Moseley

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
