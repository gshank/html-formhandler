package HTML::FormHandler;

use Moose;
use MooseX::AttributeHelpers;
extends 'HTML::FormHandler::Model';
with 'HTML::FormHandler::Fields';

use Carp;
use UNIVERSAL::require;
use Locale::Maketext;
use HTML::FormHandler::I18N; 
use HTML::FormHandler::Params;


use 5.008;
our $VERSION = '0.20';

=head1 NAME

HTML::FormHandler - form handler written in Moose 

=head1 SYNOPSIS

An example of a form class:

    package MyApp::Form::User;
    
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Model::DBIC';

    has '+item_class' => ( default => 'User' );

    has_field 'name' => ( type => 'Text' );
    has_field 'age' => ( type => 'PosInteger', apply => [ 'MinimumAge' ] );
    has_field 'birthdate' => ( type => 'DateTime' );
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


An example of a Catalyst controller that uses an HTML::FormHandler form
to update a 'Book' record:

   package MyApp::Controller::Book;
   BEGIN {
      use Moose;
      extends 'Catalyst::Controller';
   }
   use MyApp::Form::Book;
   has 'edit_form' => ( isa => 'MyApp::Form::Book', is => 'rw',
       lazy => 1, default => sub { MyApp::Form::Book->new } );

   sub book_base : Chained PathPart('book') CaptureArgs(0)
   {
      my ( $self, $c ) = @_;
      # setup
   }
   sub item : Chained('book_base') PathPart('') CaptureArgs(1)
   {
      my ( $self, $c, $book_id ) = @_;
      $c->stash( book => $c->model('DB::Book')->find($book_id) );
   }
   sub edit : Chained('item') PathPart('edit') Args(0)
   {
      my ( $self, $c ) = @_;

      $c->stash( form => $self->edit_form, template => 'book/form.tt' );
      return unless $self->edit_form->process( item => $c->stash->{book},
         params => $c->req->parameters );
      $c->res->redirect( $c->uri_for('list') );
   }

The example above creates the form as a persistent part of the application
with the Moose <C has 'edit_form' > declaration.
If you prefer, it also works fine to create the form on each request:
    
    my $form = MyApp::Form->new;
    my $validated = $form->update( item => $book, params => $params );

or, for a non-database form:

    my $form = MyApp::Form->new;
    my $validated = $form->validate( $params );
   
A dynamic form may be created in a controller using the field_list
attribute to set fields:

    my $form = HTML::FormHandler->new(
        item => $user,
        field_list => {
            fields => {
               first_name => 'Text',
               last_name => 'Text' 
            },
        },
    );


=head1 DESCRIPTION

HTML::FormHandler allows you to define HTML form fields and validators. It can
be used for both database and non-database forms, and will
automatically update or create rows in a database.

One of its goals is to keep the controller interface as simple as possible,
and to minimize the duplication of code. In most cases, interfacing your
controller to your form is only a few lines of code.

With FormHandler you'll never spend hours trying to figure out how to make a 
simple HTML change that would take one minute by hand. Because you CAN do it
by hand. Or you can automate HTML generation as much as you want, with
template widgets or pure Perl rendering classes, and stay completely in
control of what, where, and how much is done automatically. 

You can split the pieces of your forms up into logical parts and compose
complete forms from FormHandler classes, roles, fields, collections of
validations, transformations and Moose type constraints. 
You can write custom methods to 
process forms, add any attribute you like, use Moose before/after/around. 
FormHandler forms are Perl classes, so there's a lot of flexibility in what 
you can do. See L<HTML::FormHandler::Field/apply> for more info.

The L<HTML::FormHandler> module is documented here.  For more extensive 
documentation on use and a tutorial, see the manual at 
L<HTML::FormHandler::Manual>.

HTML::FormHandler does not provide a complex HTML generating facility,
but a simple, sample rendering role is provided by 
L<HTML::FormHandler::Render::Simple>, which will output HTML formatted
strings for a field or a form. There are also sample Template Toolkit
widget files in the example, documented at 
L<HTML::FormHandler::Manual::Templates>.

The typical application for FormHandler would be in a Catalyst, DBIx::Class, 
Template Toolkit web application, but use is not limited to that.


=head1 ATTRIBUTES

=head2 has_field

See L<HTML::FormHandler::Manual::Intro> for a description of the 'has_field'
field declaration syntax.

   has_field 'title' => ( type => 'Text', required => 1 );

=head2 field_list

A hashref of field definitions.

The possible keys in the field_list hashref are:

   required
   optional
   fields
   auto_required
   auto_optional

Example of a field_list hashref:

    my $field_list => {
        fields => [
            field_one => {
               type => 'Text',
               required => 1
            },
            field_two => 'Text,
         ],
     }; 

For the "auto" field_list keys, provide a list of field names.  
The field types will be determined by calling 'guess_field_type' 
in the model. For the DBIC model, the schema must be available for
this to work.  

    auto_required => ['name', 'age', 'sex', 'birthdate'],
    auto_optional => ['hobbies', 'address', 'city', 'state'],


=cut

has 'field_list' => ( isa => 'HashRef', is => 'rw', default => sub { {} } );

=head2 fields

The field definitions as built from the field_list and the 'has_field'
declarations. This is a MooseX::AttributeHelpers::Collection::Array, 
and provides clear_fields, add_field, remove_last_field, num_fields,
has_fields, and set_field_at methods.

=head2 name

The form's name.  Useful for multiple forms.
It used to construct the default 'id' for fields, and is used
for the HTML field name when 'html_prefix' is set. 
The default is "form" + a one to three digit random number.

In your form:

    has '+name' => ( default => 'userform' );

=cut

has 'name' => (
   isa     => 'Str',
   is      => 'rw',
   default => sub { return 'form' . int( rand 1000 ) }
);

# to avoid fiddly 'isa' checks when passing through $self->form 
has 'form' => ( isa => 'HTML::FormHandler', is => 'rw', weak_ref => 1,
   lazy => 1, default => sub { shift });
has 'parent' => ( is => 'rw' );

=head2 init_object

If an 'init_object' is supplied on form creation, it will be used instead 
of the 'item' to pre-populate the values in the form. This can be useful 
when populating a form from default values stored in a similar but different 
object than the one the form is creating. The 'init_object' should be either
a hash or the same type of object that the model uses (a DBIx::Class row for
the DBIC model).

See 'init_from_object' method

=cut

has 'init_object' => ( isa => 'HashRef', is => 'rw' );

=head2 ran_validation

Flag to indicate that validation has been run. This flag will be
false when the form is initially loaded and displayed, since
validation is not run until FormHandler has params to validate.
It normally shouldn't be necessary for users to check this flag.

=head2 validated

Flag that indicates if form has been validated. If you're using the
'update', 'process', or 'validate' methods, you many not 
need to use this flag, since the return value of those methods 
is this flag. You might want to use this flag if you've
written a method to replace 'update' or 'process', or you're
doing something in between update/validate, such as set a stash key.

   $form->update( ... );
   $c->stash->{...} = ...;
   return unless $form->validated;

=head2 verbose

Flag to print out additional diagnostic information. See 'dump_fields' and
'dump_validated'.

=cut

has [ 'ran_validation', 'validated', 'verbose' ] => ( isa => 'Bool', is => 'rw' );

=head2 field_name_space

Use to set the name space used to locate fields that 
start with a "+", as: "+MetaText". Fields without a "+" are loaded
from the "HTML::FormHandler::Field" name space. If 'field_name_space'
is not set, then field types with a "+" must be the complete package
name.

=cut

has 'field_name_space' => (
   isa     => 'Str|Undef',
   is      => 'rw',
   default => '',
);

=head2 num_errors

Total number of fields with errors. Set by the validation routine.

=cut

has 'num_errors' => ( isa => 'Int', is => 'rw', default => 0 );


sub updated_or_created { die "updated_or_created method has been removed" }

=head2 user_data

Place to store user data 

=cut

has 'user_data' => ( isa => 'HashRef', is => 'rw' );

=head2 ctx

Place to store application context

=cut

has 'ctx' => ( is => 'rw', weak_ref => 1, clearer => 'clear_ctx' );

=head2 language_handle, build_language_handle

Holds a Local::Maketext language handle

The builder for this attribute gets the Locale::Maketext language 
handle from the environment variable $ENV{LANGUAGE_HANDLE}, or creates 
a default language handler using L<HTML::FormHandler::I18N>

=cut

has 'language_handle' => (
   is      => 'rw',
   builder => 'build_language_handle'
);

sub build_language_handle
{
   my $lh = $ENV{LANGUAGE_HANDLE}
      || HTML::FormHandler::I18N->get_handle
      || die "Failed call to Locale::Maketext->get_handle";
   return $lh;
}

=head2 field_counter

Used for numbering fields. Used by set_order method in Field.pm. 
Useful in templates.

=cut

has 'field_counter' => (
   isa     => 'Int',
   is      => 'rw',
   default => 1
);

=head2 html_prefix

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

Also see the Field attribute "prename", a convenience function which
will return the form name + "." + field name

If you want to use some other pattern to create the HTML field name,
you could subclass 'munge_params'.

=cut

has 'html_prefix' => ( isa => 'Bool', is => 'rw' );

=head2 active_column

The column in tables used for select list that marks an option 'active'.
You might use this if all of your tables have the same 'active' column
name, instead of setting this for each field.

=cut

has 'active_column' => ( isa => 'Str', is => 'rw' );

=head2 http_method

For storing 'post' or 'get'

=cut

has 'http_method' => ( isa => 'Str', is => 'rw', default => 'post' );

=head2  action

Store the form 'action' on submission. No default value.

=cut

has 'action' => ( is => 'rw' );

=head2 submit

Store form submit field info. No default value.

=cut

has 'submit' => ( is => 'rw' );

=head2 params

Stores HTTP parameters. 
Also: set_param, get_param, clear_params, delete_param, 
has_params from Moose 'Collection::Hash' metaclass. The 'munge_params'
method is a trigger called whenever params is set.

The 'set_param' method could be used to add additional field
input that doesn't come from the HTML form, similar to a hidden field:

   my $form = MyApp::Form->new( $item, $params );
   $form->set_param('comment', 'updated by edit form');
   return unless $form->update;

(Note: 'process' clears params, so you have to use 'update' ); 

=cut

has 'params' => (
   metaclass  => 'Collection::Hash',
   isa        => 'HashRef',
   is         => 'rw',
   default    => sub { {} },
   auto_deref => 1,
   trigger    => sub { shift->munge_params(@_) },
   provides   => {
      set    => 'set_param',
      get    => 'get_param',
      clear  => 'clear_params',
      delete => 'delete_param',
      empty  => 'has_params',
   },
);

=head2 dependency

Arrayref of arrayrefs of fields. If one of a group of fields has a
value, then all of the group are set to 'required'.

  has '+dependency' => ( default => sub { [
     ['street', 'city', 'state', 'zip' ],] }
  );

=cut

has 'dependency' => ( isa => 'ArrayRef', is => 'rw' );

has '_required' => (
   metaclass  => 'Collection::Array',
   isa        => 'ArrayRef[HTML::FormHandler::Field]',
   is         => 'rw',
   default    => sub { [] },
   auto_deref => 1,
   provides   => {
      clear => 'clear_required',
      push  => 'add_required'
   }
);


# tell Moose to make this class immutable
HTML::FormHandler->meta->make_immutable;

=head1 METHODS

=head2 new 

New creates a new form object.  The constructor takes name/value pairs:

    MyForm->new(
        item    => $item,
        init_object => { name => 'Your name here', username => 'choose' }
    );

Or a single item (model row object) or item_id (row primary key)
may be supplied:

    MyForm->new( $id );
    MyForm->new( $item );

If you will be processing a persistent form with 'process', no arguments
are necessary. Do not pass in item or item_id if you use 'process',
because they will be cleared.

The common attributes to be passed in to the constructor are:

   item_id
   item
   schema
   item_class (often set in the form class)
   dependency
   field_list
   init_object

Creating a form object:

    my $form =  = HTML::FormHandler::Model::DBIC->new(
        item_id         => $id,
        item_class    => 'User', 
        schema          => $schema,
        field_list         => {
            required => {
                name    => 'Text',
                active  => 'Boolean',
            },
        },
    );

The 'item', 'item_id', and 'item_class' attributes are defined
in L<HTML::FormHandler::Model>, and 'schema' is defined in
L<HTML::FormHandler::Model::DBIC>.

FormHandler forms are handled in two steps: 1) create with 'new',
2) handle with 'process' or 'update'. FormHandler doesn't
care whether most parameters are set on new or process or update,
but a 'field_list' argument should be passed in on 'new'.

=head2 BUILD, BUILDARGS

These are called when the form object is first created (by Moose).  

A single argument is an "item" parameter if it's a reference, 
otherwise it's an "item_id".

First BUILD calls the build_fields method, which reads the field_list and creates
the fields object array.

Then 'init_from_object' is called to load each field's internal value
from the 'init_object' or from the 'item', followed by 'load_options'
to load values for select fields.

=cut

sub BUILDARGS
{
   my $class = shift;

   if ( @_ == 1 )
   {
      my $id = $_[0];
      return { item => $id, item_id => $id->id } if (blessed $id);
      return { item_id => $id };
   }
   return $class->SUPER::BUILDARGS(@_); 
}

sub BUILD
{
   my $self = shift;

   $self->build_fields;    # create the form fields
   return if defined $self->item_id && !$self->item;
   $self->init_from_object;    # load values from object, if item exists;
   $self->load_options;        # load options -- need to do after loading item
   $self->dump_fields if $self->verbose;
   return;
}


=head2 process

A convenience method for persistent FormHandler instances. This method
calls 'clear' and 'update' to processes a form:

   my $validated = $form->process( item => $book, 
       params => $c->req->parameters );

or:

   my $validated = $form->process( item_id => $item_id,
       schema => $schema, params => $c->req->parameters );

If you set attributes that are not cleared and you have a persistent form,
you must either set that attribute on each request or clear it.

If your form is not persistent, you should call 'update' instead, because 
this method clears the item and item_id.

This method can also be used for non-database forms:

    $form->process( params => $params );

This method returns the 'validated' flag. (C<< $form->validated >>)

=cut 

sub process
{
   my ( $self, @args ) = @_;
   $self->clear;
   return $self->update(@args);
}

=head2 update

This is the method to call to update the form if your form is not persistent.
Pass in item or item_id/schema and parameters. 

    my $form = MyApp::Form::Book->new;
    $form->update( item => $item, schema => $schema );

It set attributes from the parameters passed in, calls 'init_from_object',
loads select options, calls validate if there are parameters, and calls
update_model if the form validated.  It returns the 'validated' flag.


=cut

sub update
{
   my ( $self, @args ) = @_;

   warn "HFH: update ", $self->name, "\n" if $self->verbose;
   $self->setup_form(@args);
   $self->validate_form if $self->has_params;
   $self->update_model if $self->validated;
   $self->dump_fields if $self->verbose;
   return $self->validated;
}

=head2 validate

This is the non-database form processing method.

  $self->validate( $params );

or

 $self->validate( key => 'something', params => $params );

It will call the validate_form method to perform validation
on the fields.

=cut

sub validate
{
   my ( $self, @args ) = @_;

   warn "HFH: validate ", $self->name, "\n" if $self->verbose;
   $self->clear_state;
   $self->clear_values;
   $self->setup_form( @args );
   return unless $self->has_params;
   return $self->validate_form;
}

=head2 validate_form

The validation routine

The method does the following:
 
    1) sets required dependencies
    2) trims params and saves in field 'input' attribute
    3) calls the 'fields_validate' routine from HTML::FormHandler::Fields
    4) calls cross_validate for validating fields that might be blank and
       checking more complex dependencies. (If this field, then not that field...) 
    5) calls the model's validation method. By default, this only checks for
       database uniqueness.
    6) counts errors, sets 'ran_validation' and 'validated' flags
    7) returns 'validated' flag

Returns true if validation succeeds, false if validation fails.

=cut

sub validate_form
{
   my $self = shift;
   my $params = $self->params; 
   $self->set_dependency;    # set required dependencies
   foreach my $field ( $self->fields )
   {
      # Trim values and move to "input" slot
      if ( exists $params->{$field->full_name} )
      {
         # trim_value may be replaced by some kind of filter in the future
         $field->input( $field->trim_value( $params->{$field->full_name} ) )
      }
      elsif ( $field->has_input_without_param )
      {
         $field->input( $field->input_without_param );
      }
   }

   $self->fields_validate;
      
   $self->cross_validate($params);
   # model specific validation 
   $self->validate_model;
   $self->clear_dependency;

   # count errors 
   my $errors;
   for ( $self->fields )
   {
      $errors++ if $_->has_errors;
   }
   $self->num_errors( $errors || 0 );
   $self->ran_validation(1);
   $self->validated( !$errors );
   $self->dump_validated if $self->verbose;
   $_->clear_input for $self->fields;

   return $self->validated;
}


=head2 db_validate

Convenience function to allow validating values in the database object.
This is not intended for use with HTML forms. If you've written some nice
validators for form data, but there is unvalidated data in the
database, this function could be used in a script to check the validity
of values in the database. All it does is copy the fill-in-form fields
to the parameter hash and call validate. See the test script in 
L<HTML::FormHandler::Manual::Intro>, and the t/db_validate.t test.

   my $form = MyApp::Form::Book->new( item => $item );
   my $validated = $form->db_validate;

=cut

sub db_validate
{
   my $self = shift;
   foreach my $field ($self->fields)
   {
      $self->set_param( $field->full_name, $field->fif );
   }
   return $self->validate;
}

=head2 clear

Calls clear_state,clear_params, clear_model (in the model), and clears 'ctx'

=cut

sub clear
{ 
   my $self = shift;
   warn "HFH: clear ", $self->name, "\n" if $self->verbose;
   $self->clear_state;
   $self->clear_params;
   $self->clear_model;
   $self->clear_ctx;
}

=head2 clear_state

Clears out state information in the form.  

   validated
   ran_validation
   num_errors
   fields: errors, fif  
   params

=cut

sub clear_state
{
   my $self = shift;
   $self->validated(0);
   $self->ran_validation(0);
   $self->num_errors(0);
   $self->clear_errors;
   $self->clear_fif;
}

=head2 clear_values

Clears field values

=cut

sub clear_values
{
   my $self = shift;
   $_->clear_value for $self->fields;
}

=head2 clear_errors

Clears field errors

=cut

sub clear_errors
{
   my $self = shift;
   $_->clear_errors for $self->fields;
}

=head2 clear_fif

Clears fif values

=cut

sub clear_fif
{
   my $self = shift;
   $_->clear_fif for $self->fields;
}

=head2 dump_fields

Dumps the fields of the form for debugging. This method is called when
the verbose flag is turned on.

=cut

sub dump_fields
{
   my $self = shift;

   warn "HFH: ------- fields for form ", $self->name, "-------\n";
   for my $field ( $self->sorted_fields )
   {
      $field->dump;
   }
   warn "HFH: ------- end fields -------\n";
}

=head2 dump_validated

For debugging, dump the validated fields. This method is called when the
verbose flag is on.

=cut

sub dump_validated
{
   my $self = shift;
   warn "HFH: fields validated:\n";
   warn "HFH: ", $_->name, ": ", ( $_->has_errors ? join( ' | ', $_->errors ) : 'validated' ), "\n"
      for $self->fields;
}

=head2 fif  (fill in form)

Returns a hash of values suitable for use with HTML::FillInForm
or for filling in a form with C<< $form->fif->{fieldname} >>.
The fif value for a 'title' field in a TT form:

   [% form.fif.title %] 

=cut

sub fif
{
   my $self = shift;

   my $prefix = '';
   $prefix = $self->name . "." if $self->html_prefix;
   my $params;
   foreach my $field ( $self->fields )
   {
      next if $field->password;
      next unless $field->fif;
      my $fif = $field->fif;
      if ( ref $fif eq 'HASH' )
      {
          foreach my $key ( keys %{$fif} )
          {
             $params->{ $prefix . $key } = $fif->{$key};
          }
      }
      else
      {
         $params->{ $prefix . $field->full_name } = $field->fif;
      }
   }
   return $params;
}

=head2 values

Returns a hashref of all field values. Useful for non-database forms.
The 'fif' and 'values' hashrefs will be the same unless there's a
difference in format between the HTML field values (in fif) and the saved value
or unless the field 'name' and 'accessor' are different. 'fif' returns
a hash with the field names for the keys and the field's 'fif' for the
values; 'values' returns a hash with the field accessors for the keys, and the
field's 'value' for the the values. 

=cut

sub values
{
   my $self = shift;
   my $values;
   foreach my $field( $self->fields )
   {
      next if $field->noupdate;
      next unless $field->has_value;
      next if $field->has_parent;
      $values->{$field->accessor} = $field->value unless $field->clear;
      $values->{$field->accessor} = undef if $field->clear; 
   }
   return $values;
}

=head2 field NAME

This is the method that is usually called in your templates to
access a field:

    [% f = form.field('title') %]

Searches for and returns a field named "NAME".
Dies on not found.

    my $field = $form->field('first_name');

Pass a second true value to not die on errors.
 
    my $field = $form->field('something', 1 );

=head2 value

Convenience function to return the value of the field. Returns
undef if field not found.

=cut

sub value
{
   my ( $self, $fieldname ) = @_;
   my $field = $self->field( $fieldname, 1 ) || return;
   return $field->value; 
}

=head2 field_exists

Returns true (the field) if the field exists

=cut

sub field_exists
{
   my ( $self, $name ) = @_;
   return $self->field( $name, 1 );
}


=head2 munge_params

Munges the parameters when they are set.  Currently just adds 
keys without the "html_prefix". Can be subclassed. You might
want to use this if you want to use different names in your
html form than your field names.

=cut

sub munge_params
{
   my ( $self, $params, $attr ) = @_;
   my $new_params = HTML::FormHandler::Params->expand_hash($params);
   if ( $self->html_prefix )
   {
      $new_params = $new_params->{$self->name};
   }
   my $final_params = {%{$params}, %{$new_params}};
   $self->{params} = $final_params;
}

=head2 cross_validate

This method is useful for cross checking values after they have been saved 
as their final validated value, and for performing more complex dependency
validation.

This method is called even if some fields did not validate.

=cut

sub cross_validate { 1 }

=head2 has_error

Returns true if validate has been called and the form did not
validate.

=cut

sub has_error
{
   my $self = shift;
   return $self->ran_validation && !$self->validated;
}

=head2 has_errors

Checks the fields for errors and return true or false.

=cut

sub has_errors
{
   for ( shift->fields )
   {
      return 1 if $_->has_errors;
   }
   return 0;
}

=head2 error_fields

Returns list of fields with errors.

=cut

sub error_fields
{
   return grep { $_->has_errors } shift->sorted_fields;
}

=head2 error_field_names

Returns a list of the names of the fields with errors.

=cut

sub error_field_names
{
   my $self         = shift;
   my @error_fields = $self->error_fields;
   return map { $_->name } @error_fields;
}

=head2 errors

Returns a single array with all field errors

=cut

sub errors
{
   my $self         = shift;
   my @error_fields = $self->error_fields;
   return map { $_->errors } @error_fields;
}


=head2 uuid

Generates a hidden html field with a unique ID using Data::UUID which
the can be used to check for duplicate form postings.
Creates following html:

  <input type="hidden" name="form_uuid" value="..some_uuid..">

Call with:

  [% form.uuid %]

=cut

sub uuid
{
   my $form = shift;
   require Data::UUID;
   my $uuid = Data::UUID->new->create_str;
   return qq[<input type="hidden" name="form_uuid" value="$uuid">];
}

=head1 METHODS used in internal processing

Most users won't need these methods.


=head2 setup_form

Puts parameters into attributes, initializes fields, loads options

=cut

sub setup_form
{
   my ($self, @args) = @_;
   if( @args == 1 )
   {
      $self->params( $args[0] );
   }
   elsif ( @args > 1 )
   {
      my $hashref = {@args};
      while ( my ($key, $value) = each %{$hashref} )
      {
         $self->$key($value) if $self->can($key);
      } 
   }
   $self->clear_fif;
   $self->init_from_object;
   $self->load_options;
}
=head2 init_from_object

Populates the field 'value' attributes from an 'init_object' or $form->item
by calling a form's custom init_value_$fieldname method, passing in
the field and the item. 

The value is stored in both the 'init_value' attribute, and the 'value'
attribute.

=cut

sub init_from_object
{
   my ( $self, $node, $item ) = @_;
   $node ||= $self;
   $self->item( $self->build_item ) if $self->item_id && !$self->item;
   $item ||= $self->init_object || $self->item || return;
   warn "HFH: init_from_object ", $self->name, "\n" if $self->verbose;
   for my $field ( $node->fields )
   {
      if( $field->isa( 'HTML::FormHandler::Field::Compound' ) ){
          my $accessor = $field->accessor;
          my $new_item = $item->$accessor;
          $self->init_from_object( $field, $new_item );
      }
      else{
         my @values;
         if ( $field->_can_init )
         {
            @values = $field->_init( $field, $item );
            my $value = @values > 1 ? \@values : shift @values;
            $field->init_value($value) if $value;
            $field->value($value) if $value;
         }
         else
         {
            $self->init_value( $field, $item );
         }
     }
   }
}

=head2 init_value

This method populates a form field's value from the item object.

=cut

sub init_value
{
   my ( $self, $field, $item ) = @_;
   my $accessor = $field->accessor;
   
   my @values;
   if (blessed $item && $item->can($accessor))
   {
      @values = $item->$accessor;
   }
   elsif ( exists $item->{$accessor} )
   {
      @values = $item->{$accessor};
   }
   else
   {
      return;
   }
   my $value = @values > 1 ? \@values : shift @values;
   $field->init_value($value);
   $field->value($value);
}

=head2 load_options

For 'Select' or 'Multiple' fields (fields which have an 'options' method),
call an "options_$field_name" method if it exists (is defined in your form), 
or else call the model's "lookup_options" to retrieve the list of options
from the database.

An example of an 'options' routine in your form class:

    sub options_fruit {
        return (
            1 => 'Apple',
            2 => 'Grape',
            3 => 'Cherry',
        );
    }

See L<HTML::FormHandler::Field::Select>

=cut

sub load_options
{
   my ( $self, $node, $model_stuff ) = @_;

   $node ||= $self;
   warn "HFH: load_options ", $node->name, "\n" if $self->verbose;
   for my $field ( $node->fields ){
       if( $field->isa( 'HTML::FormHandler::Field::Compound' ) ){
           my $new_model_stuff = $self->compute_model_stuff( $field, $model_stuff );
           $self->load_options( $field, $new_model_stuff );
       }
       else {
           $self->load_field_options($field, $model_stuff);
       }
   }
}

=head2 load_field_options

Load the options array into a field. Pass in a field object,
and, optionally, an options array.

=cut

sub load_field_options
{
   my ( $self, $field, $model_stuff, @options ) = @_;

   return unless $field->can('options');

   my $method = 'options_' . $field->name;
   @options =
        $self->can($method)
      ? $self->$method($field)
      : $self->lookup_options($field, $model_stuff)
      unless @options;
   return unless @options;

   @options = @{ $options[0] } if ref $options[0];
   croak "Options array must contain an even number of elements for field " . $field->name
      if @options % 2;

   my @opts;
   push @opts, { value => shift @options, label => shift @options } while @options;

   $field->options( \@opts ) if @opts;
}

=head2 set_dependency

Process the dependency lists 

=cut 

sub set_dependency
{
   my $self = shift;

   my $depends = $self->dependency || return;
   my $params = $self->params;
   for my $group (@$depends)
   {
      next if @$group < 2;
      # process a group of fields
      for my $name (@$group)
      {
         # is there a value?
         my $value = $params->{$name};
         next unless defined $value;
         # The exception is a boolean can be zero which we count as not set.
         # This is to allow requiring a field when a boolean is true.
         my $field = $self->field_exists($name);
         next if $self->field($name)->type eq 'Boolean' && $value == 0;
         if ( ref $value )
         {
            # at least one value is non-blank
            next unless grep { /\S/ } @$value;
         }
         else
         {
            next unless $value =~ /\S/;
         }
         # one field was found non-blank, so set all to required
         for (@$group)
         {
            my $field = $self->field($_);
            next unless $field && !$field->required;
            $self->add_required($field);        # save for clearing later.
            $field->required(1);
         }
         last;
      }
   }
}

sub clear_dependency
{
   my $self = shift;

   $_->required(0) for $self->_required;
   $self->clear_required;
}

sub name_prefix
{
  die "The name_prefix attribute has been removed from HFH. Use 'html_prefix' and set the form name instead.";
}

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

L<HTML::FormHandler::Field>

L<HTML::FormHandler::Model::DBIC>

L<HTML::FormHandler::Moose>


=head1 AUTHOR

gshank: Gerda Shank <gshank@cpan.org>

Based on the original source code of L<Form::Processor> by Bill Moseley

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose;
1;
