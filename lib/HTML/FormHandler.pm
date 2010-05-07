package HTML::FormHandler;

use Moose;
with 'HTML::FormHandler::Model', 'HTML::FormHandler::Fields',
    'HTML::FormHandler::BuildFields',
    'HTML::FormHandler::Validate::Actions',
    'HTML::FormHandler::TraitFor::I18N';
with 'HTML::FormHandler::InitResult';
with 'HTML::FormHandler::Widget::ApplyRole';
with 'MooseX::Traits';

use Carp;
use Class::MOP;
use HTML::FormHandler::Result;

use 5.008;

# always use 5 digits after decimal because of toolchain issues
our $VERSION = '0.31003';

=head1 NAME

HTML::FormHandler - form handler written in Moose

=head1 SYNOPSIS

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


An example of a custom form class (you could also use a 'field_list'
like the dynamic form example if you don't want to use the 'has_field'
field declaration sugar):

    package MyApp::Form::User;

    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+item_class' => ( default => 'User' );

    has_field 'name' => ( type => 'Text' );
    has_field 'age' => ( type => 'PosInteger', apply => [ 'MinimumAge' ] );
    has_field 'birthdate' => ( type => 'DateTime' );
    has_field 'birthdate.month' => ( type => 'Month' ); # Explicitly split
    has_field 'birthdate.day' => ( type => 'MonthDay' ); # fields for renderer
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
created in using the 'field_list' attribute to set fields:

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

HTML::FormHandler maintains a clean separation between form construction
and form rendering. It allows you to define your forms and fields in a
number of flexible ways. Although it provides renderers for HTML, you
can define custom renderers for any kind of presentation.

Although documentation in this file provides some overview, it is mainly
intended for API documentation. See L<HTML::FormHandler::Manual::Intro>
for a more detailed introduction.

HTML::FormHandler allows you to define form fields and validators. It can
be used for both database and non-database forms, and will
automatically update or create rows in a database. It can be used
to process structured data that doesn't come from an HTML form.

One of its goals is to keep the controller/application program interface as 
simple as possible, and to minimize the duplication of code. In most cases, 
interfacing your controller to your form is only a few lines of code.

With FormHandler you'll never spend hours trying to figure out how to make a
simple HTML change that would take one minute by hand. Because you CAN do it
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
more atomic roles which are automatically applied to fields and form if a 
'render' method does not already exist. See
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
the form definitions. If no initial data object has been provided, the form
will be empty. Most attributes can be set on either 'new' or 'process'.
The common attributes to be passed in to the constructor for a database form
are either item_id and schema or item:

   item_id  - database row primary key
   item     - database row object
   schema   - (for DBIC) the DBIx::Class schema

The following are occasionally passed in, but are more often set
in the form class:

   item_class  - source name of row
   dependency  - (see dependency)
   field_list  - and array of field definitions
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

=head3 params

Parameters are passed in or already set when you call 'process'.
HFH gets data to validate and store in the database from the params hash.
If the params hash is empty, no validation is done, so it is not necessary
to check for POST before calling C<< $form->process >>.

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

You can add an additional param when setting params:

   $form->process( params => { %{$c->req->params}, new_param  => 'something' } );

=head2 Getting data out

=head3 fif  (fill in form)

Returns a hash of values suitable for use with HTML::FillInForm
or for filling in a form with C<< $form->fif->{fieldname} >>.
The fif value for a 'title' field in a TT form:

   [% form.fif.title %]

Or you can use the 'fif' method on individual fields:

   [% form.field('title').fif %]

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
definitions) is the short class name of the field class.

=head3 has_field

The most common way of declaring fields is the 'has_field' syntax.
Using the 'has_field' syntax sugar requires C< use HTML::FormHandler::Moose; >
or C< use HTML::FormHandler::Moose::Role; > in a role.
See L<HTML::FormHandler::Manual::Intro>

   use HTML::FormHandler::Moose;
   has_field 'field_name' => ( type => 'FieldClass', .... );

=head3 field_list

A 'field_list' is an array of field definitions which can be used as an
alternative to 'has_field' in small, dynamic forms.

    field_list => [
       field_one => {
          type => 'Text',
          required => 1
       },
       field_two => 'Text,
    ]

Or the field list can be set inside a form class, when you want to
add fields to the form depending on some other state.

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

=head3 active

If a form has a variable number of fields, fields which are not always to be
used should be defined as 'inactive':

   has_field 'foo' => ( type => 'Text', inactive => 1 );

Then the field name can be specified in the 'active' array, either on 'new',
or on 'process':

   my $form = MyApp::Form->new( active => ['foo'] );
   ...
   $form->process( active => ['foo'] );

Fields specified as active on new will have the 'inactive' flag cleared, and so:
those fields will be active for the life of the form object. Fields specified as
active on 'process' will have the field's '_active' flag set just for the life of the
request.

=head3 field_name_space

Use to set the name space used to locate fields that
start with a "+", as: "+MetaText". Fields without a "+" are loaded
from the "HTML::FormHandler::Field" name space. If 'field_name_space'
is not set, then field types with a "+" must be the complete package
name.

=head3 fields

The array of fields, objects of L<HTML::FormHandler::Field> or its subclasses.
A compound field will itself have an array of fields,
so this is a tree structure.

=head3 field($name)

This is the method that is usually called to access a field:

    my $title = $form->field('title')->value;
    [% f = form.field('title') %]

    my $city = $form->field('addresses.0.city')->value;

Pass a second true value to die on errors.

=head2 Constraints and validation

Most validation is performed on a per-field basis, and there are a number
of different places in which validation can be performed.

=head3 Apply actions

The 'actions' array contains a sequence of transformations and constraints
(including Moose type constraints) which will be applied in order. The 'apply'
sugar is used to add to the actions array in field classes. In a field definition
elements of the 'apply' array will added to the 'actions' array.

The current value of the field is passed in to the subroutines, but it has
no access to other field information. If you need more information to
perform validation, you should use one of the other validation methods.

L<HTML::FormHandler::Field::Compound> fields receive as value
a hash containing values of their child fields - this may be used for
easy creation of objects (like DateTime).
See L<HTML::FormHandler::Field/apply> for more documentation.

   has_field 'test' => ( apply => [ 'MyConstraint',
                         { check => sub {... },
                           message => '....' },
                         { transform => sub { ... },
                           message => '....' }
                         ] );

=head3 Field class validate method

The 'validate' method can be used in custom field classes to perform additional
validation.  It has access to the field ($self).  This method is called after the
actions are performed.

=head3 Form class validation for individual fields

You can define a method in your form class to perform validation on a field.
This method is the equivalent of the field class validate method except it is
in the form class, so you might use this
validation method if you don't want to create a field subclass.

It has access to the form ($self) and the field.
This method is called after the field class 'validate' method, and is not
called if the value for the field is empty ('', undef). (If you want an
error message when the field is empty, use the 'required' flag and message.)
The name of this method can be set with 'set_validate' on the field. The
default is 'validate_' plus the field name:

   sub validate_testfield { my ( $self, $field ) = @_; ... }

If the field name has dots they should be replaced with underscores.

=head3 validate

(This method used to be called 'cross_validate'. It was renamed to 'validate'
to make the api more consistent.)
This is a form method that is useful for cross checking values after they have
been saved as their final validated value, and for performing more complex
dependency validation. It is called after all other field validation is done,
and whether or not validation has succeeded, so it has access to the
post-validation values of all the fields.

This is the best place to do validation checks that depend on the values of
more than one field.

=head2 Accessing errors

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

=head2 Miscellaneous attributes

=head3 name

The form's name.  Useful for multiple forms.
It is used to construct the default 'id' for fields, and is used
for the HTML field name when 'html_prefix' is set.
The default is "form" + a one to three digit random number.

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

=head3 verbose

Flag to dump diagnostic information. See 'dump_fields' and
'dump_validated'.

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

=head2 For use in HTML

   http_method - For storing 'post' or 'get'
   action - Store the form 'action' on submission. No default value.
   enctype - Request enctype
   uuid - generates a string containing an HTML field with UUID

=cut

# Moose attributes
has 'name' => (
    isa     => 'Str',
    is      => 'rw',
    default => sub { return 'form' . int( rand 1000 ) }
);
# for consistency in api with field nodes
has 'form' => (
    isa      => 'HTML::FormHandler',
    is       => 'rw',
    weak_ref => 1,
    predicate => 'has_form',
    lazy     => 1,
    default  => sub { shift }
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
        'is_valid'
    ],
);

sub build_result {
    my $self = shift;
    my $result = HTML::FormHandler::Result->new( name => $self->name, form => $self );
    if ( $self->widget_form ) {
        $self->apply_widget_role( $result, $self->widget_form, 'Form' );
    }
    return $result;
}

has 'field_traits' => ( is => 'ro', traits => ['Array'], isa => 'ArrayRef',
    default => sub {[]}, handles => { 'has_field_traits' => 'count' } );
has 'widget_name_space' => ( is => 'ro', isa => 'ArrayRef[Str]', default => sub {[]} );
has 'widget_form'       => ( is => 'ro', isa => 'Str', default => 'Simple' );
has 'widget_wrapper'    => ( is => 'ro', isa => 'Str', default => 'Simple' );
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
   

# object with which to initialize
has 'init_object'         => ( is => 'rw', clearer => 'clear_init_object' );
has 'reload_after_update' => ( is => 'rw', isa     => 'Bool' );
# flags
has [ 'verbose', 'processed', 'did_init_obj' ] => ( isa => 'Bool', is => 'rw' );
has 'user_data' => ( isa => 'HashRef', is => 'rw' );
has 'ctx' => ( is => 'rw', weak_ref => 1, clearer => 'clear_ctx' );
has 'html_prefix'   => ( isa => 'Bool', is  => 'ro' );
has 'active_column' => ( isa => 'Str',  is  => 'ro' );
has 'http_method'   => ( isa => 'Str',  is  => 'ro', default => 'post' );
has 'enctype'       => ( is  => 'rw',   isa => 'Str' );
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
has 'action' => ( is => 'rw' );
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

{
    use Moose::Util::TypeConstraints;

    my $tc = subtype as 'ClassName';
    coerce $tc, from 'Str', via { Class::MOP::load_class($_); $_ };

    has 'params_class' => (
        is      => 'ro',
        isa     => $tc,
        coerce  => 1,
        default => 'HTML::FormHandler::Params',
    );

    no Moose::Util::TypeConstraints;
}

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

    $self->apply_field_traits if $self->has_field_traits;
    $self->apply_widget_role( $self, $self->widget_form, 'Form' )
        if ( $self->widget_form && !$self->can('render') );
    $self->_build_fields;    # create the form fields (BuildFields.pm)
    $self->build_active if $self->has_active; # set optional fields active
    return if defined $self->item_id && !$self->item;
    # load values from object (if any)
    if ( my $init_object = $self->item || $self->init_object ) {
        $self->_result_from_object( $self->result, $init_object );
    }
    else {
        $self->_result_from_fields( $self->result );
    }
    $self->dump_fields if $self->verbose;
    return;
}

sub process {
    my $self = shift;

    warn "HFH: process ", $self->name, "\n" if $self->verbose;
    $self->clear if $self->processed;
    $self->setup_form(@_);
    $self->validate_form      if $self->has_params;
    $self->update_model       if $self->validated;
    $self->after_update_model if $self->validated;
    $self->dump_fields        if $self->verbose;
    $self->processed(1);
    return $self->validated;
}

sub run {
    my $self = shift;
    $self->setup_form(@_);
    $self->validate_form      if $self->has_params;
    $self->update_model       if $self->validated;
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
    $self->clear_ctx;
    $self->processed(0);
    $self->did_init_obj(0);
    $self->clear_result;
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
    return map { $_->all_errors } @error_fields;
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
    $self->_apply_actions;
    $self->validate;           # empty method for users
    $self->validate_model;     # model specific validation
    $self->fields_set_value;
    $self->_clear_dependency;
    $self->get_error_fields;
    $self->ran_validation(1);
    $self->dump_validated if $self->verbose;
    return $self->validated;
}

sub validate { 1 }

sub has_errors { shift->has_error_fields }
sub num_errors { shift->num_error_fields }

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
    # initialization of Repeatable fields and Select options
    # will be done in _result_from_object when there's an initial object
    # in _result_from_input when there are params
    # and by _result_from_fields for empty forms

    if ( !$self->did_init_obj ) {
        if ( my $init_object = $self->item || $self->init_object ) {
            $self->_result_from_object( $self->result, $init_object ); 
        }
        elsif ( !$self->has_params ) {
            # no initial object. empty form form must be initialized
            $self->_result_from_fields( $self->result );
        }
    }
    # There's some weirdness here because of trying to support supplying
    # the db object in the ->new. May change to not support that? 
    my %params = ( %{ $self->params } );
    if ( $self->has_params ) {
        $self->clear_result;
        $self->_result_from_input( $self->result, \%params, 1 );
    }

}

# if active => [...] is set at process time, set 'active' flag
sub set_active {
    my $self = shift;
    return unless $self->has_active;
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

# if active => [...] is set at build time, remove 'inactive' flags
sub build_active {
    my $self = shift;
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
            if ( ref $value ) {
                # at least one value is non-blank
                next unless grep { /\S/ } @$value;
            }
            else {
                next unless $value =~ /\S/;
            }
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

sub apply_field_traits {
    my $self = shift; 
    my $fmeta = HTML::FormHandler::Field->meta;
    $fmeta->make_mutable;
    Moose::Util::apply_all_roles( $fmeta, @{$self->field_traits});
    $fmeta->make_immutable;
}

sub get_default_value { }
sub _can_deflate { }

=head1 SUPPORT

IRC:

  Join #formhandler on irc.perl.org

Mailing list:

  http://groups.google.com/group/formhandler

Code repository:

  http://github.com/gshank/html-formhandler/tree/master

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

Initially based on the source code of L<Form::Processor> by Bill Moseley

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
