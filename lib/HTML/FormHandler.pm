package HTML::FormHandler;

use Moose;
use MooseX::AttributeHelpers;
extends 'HTML::FormHandler::Model';

use Carp;
use UNIVERSAL::require;
use Locale::Maketext;
use HTML::FormHandler::I18N;    # base class for language files

use 5.008;
our $VERSION = '0.13';

=head1 NAME

HTML::FormHandler - form handler written in Moose 

=head1 SYNOPSIS

HTML::FormHandler allows you to define HTML form fields and validators, and will
automatically update or create rows in a database, although it can also be
used for non-database forms.

One of its goals is to keep the controller interface as simple as possible,
and to minimize the duplication of code. 

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

The example above has the forms as a persistent part of the application.
If you prefer, it also works fine to create the form on each request:
    
    my $form = MyApp::Form->new;
    my $validated = $form->update( item => $book, params => $params );

or, for a non-database form:

    my $form = MyApp::Form->new;
    my $validated = $form->validate( $params );
   
An example of a form class:

    package MyApp::Form::User;
    
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Model::DBIC';

    has '+item_class' => ( default => 'User' );

    has_field 'name' => ( type => 'Text' );
    has_field 'age' => ( type => 'PosInteger' );
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

    sub validate_age {
        my ( $self, $field ) = @_;
        $field->add_error('Sorry, you must be 18')
            if $field->value < 18;
    }

    no HTML::FormHandler::Moose;
    1;

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

HTML::FormHandler differs from other form frameworks in that each form is
a Perl object. This allows concentrating form definition and validation in
one place, and permits easy customization.

HTML::FormHandler does not provide a complex HTML generating facility,
but a simple, sample rendering role is provided by 
L<HTML::FormHandler::Render::Simple>, which will output HTML formatted
strings for a field or a form. There are also sample Template Toolkit
widget files in the example, documented at 
L<HTML::FormHandler::Manual::Templates>.

The typical application for FormHandler would be in a Catalyst, DBIx::Class, 
Template Toolkit web application, but use is not limited to that.

The L<HTML::FormHandler> module is documented here.  For more extensive 
documentation on use and a tutorial, see the manual at 
L<HTML::FormHandler::Manual>.


=head1 ATTRIBUTES

=head2 has_field

This is not actually a Moose attribute. It is just sugar to allow the
declarative specification of fields. It will not create accessors for the
fields. The 'type' is not a Moose type, but an L<HTML::FormHandler::Field>
type. To use this sugar, you must do 

   use HTML::FormHandler::Moose;

instead of C< use Moose; >. Don't forget C< no HTML::FormHandler::Moose; > at
the end of the package. Use the syntax:

   has_field 'title' => ( type => 'Text', required => 1 );
   has_field 'authors' => ( type => 'Select' );

instead of:

   has '+field_list' => ( default => sub { {
         fields => {
             title => {
                type => 'Text',
                required => 1,
             },
             authors => 'Select',
             } 
          }
       }
    );
 
or:

   sub field_list {
      return {
         fields => {
            title => {
               type => 'Text',
               required => 1,
            },
            authors => 'Select',
         }
      }            
   }
         
Fields specified in a field_list will overwrite fields specified with 'has_field'.
After processing, fields live in the 'fields' array, and can be accessed with the
field method: C<< $form->field('title') >>. 


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
in the model.  

    auto_required => ['name', 'age', 'sex', 'birthdate'],
    auto_optional => ['hobbies', 'address', 'city', 'state'],


=cut

has 'field_list' => ( isa => 'HashRef', is => 'rw', default => sub { {} } );

=head2 name

The form's name.  Useful for multiple forms.
It's also used to construct the default 'id' for fields. 
The default is "form" + a one to three digit random number.

In your form:

    has '+name' => ( default => 'userform' );

=cut

has 'name' => (
   isa     => 'Str',
   is      => 'rw',
   default => sub { return 'form' . int( rand 1000 ) }
);


=head2 init_object

If an 'init_object' is supplied on form creation, it will be used instead 
of the 'item' to pre-populate the values in the form.

This can be useful when populating a form from default values stored in
a similar but different object than the one the form is creating.

See 'init_from_object' method

=cut

has 'init_object' => ( isa => 'HashRef', is => 'rw' );

=head2 ran_validation

Flag to indicate that validation has been run.

=head2 validated

Flag that indicates if form has been validated

=head2 verbose

Flag to print out additional diagnostic information 

=head2 readonly

"Readonly" is not used by F::P.

=cut

has [ 'ran_validation', 'validated', 'verbose', 'readonly' ] => ( isa => 'Bool', is => 'rw' );

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

Total number of errors

=cut

has 'num_errors' => ( isa => 'Int', is => 'rw', default => 0 );

=head2 updated_or_created

Flag indicating whether the db record in the item already existed 
(was updated) or was created

=cut

has 'updated_or_created' => ( isa => 'Str|Undef', is => 'rw' );

=head2 user_data

Place to store user data 

=cut

has 'user_data' => ( isa => 'HashRef', is => 'rw' );

=head2 ctx

Place to store application context

=cut

has 'ctx' => ( is => 'rw', weak_ref => 1 );

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

Also see the Field attribute "prename", a convenience function which
will return the form name + "." + field name

=cut

has 'html_prefix' => ( isa => 'Bool', is => 'rw' );

=head2 name_prefix

You don't need this attribute unless you have a compound field. 
Prefix is used for field names in compound fields.  The collection
of fields can be a complete form.  An example might be a field
that represents a DateTime object, but is made up of separate
day, month, and year fields. Adds the 'name_prefix' plus a dot to
the beginning of the field name.

=cut

has 'name_prefix' => ( isa => 'Str', is => 'rw' );

=head2 active_column

The column in tables used for select list that marks an option 'active'

=cut

has 'active_column' => ( isa => 'Str', is => 'rw' );

=head2 http_method

For storing 'post' or 'get'

=cut

has 'http_method' => ( isa => 'Str', is => 'rw', default => 'post' );

=head2  action

Store the form 'action' on submission

=cut

has 'action' => ( is => 'rw' );

=head2 submit

Store form submit field info

=cut

has 'submit' => ( is => 'rw' );

=head2 params

Stores HTTP parameters. 
Also: set_param, get_param, _params, delete_param, from
Moose 'Collection::Hash' metaclass.

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

=head2 fields

The field definitions as built from the field_list. This is a
MooseX::AttributeHelpers::Collection::Array, and provides
clear_fields, add_field, remove_last_field, num_fields,
has_fields, and set_field_at methods.

=cut

has 'fields' => (
   metaclass  => 'Collection::Array',
   isa        => 'ArrayRef[HTML::FormHandler::Field]',
   is         => 'rw',
   default    => sub { [] },
   auto_deref => 1,
   provides   => {
      clear => 'clear_fields',
      push  => 'add_field',
      pop   => 'remove_last_field',
      count => 'num_fields',
      empty => 'has_fields',
      set   => 'set_field_at',
   }
);

has 'required' => (
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

=head2 dependency

Arrayref of arrayrefs of fields. If one of a group of fields has a
value, then all of the group are set to 'required'.

  has '+dependency' => ( default => sub { [
     ['street', 'city', 'state', 'zip' ],] }
  );

    
=cut

has 'dependency' => ( isa => 'ArrayRef', is => 'rw' );

=head2 parent_field

This value can be used to link a sub-form to the parent field.

If a form has a parent_field associated with it, errors in the field will be 
pushed onto the parent_field instead of the current field. 
This stores a weakened value.

=cut

has 'parent_field' => ( is => 'rw', weak_ref => 1 );

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
are necessary. Do not pass in item, item_id, or schema if you use 'process',
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

First BUILD calls the build_form method, which reads the field_list and creates
the fields object array.

Then 'init_from_object' is called to load each field's internal value
from the 'init_object' or from the 'item', followed by 'load_options'
to load values for select fields.

=cut

sub BUILDARGS
{
   my ( $class, @args ) = @_;

   if ( @args == 1 )
   {
      my $id = $args[0];
      return { item => $id, item_id => $id->id } if (blessed $id);
      return { item_id => $id };
   }
   return {@args};
}

sub BUILD
{
   my $self = shift;

   warn "HFH: build_form for ", $self->name, ", ", ref($self), "\n" if
      $self->verbose;
   $self->build_form;    # create the form fields
   return if defined $self->item_id && !$self->item;
   $self->init_from_object;    # load values from object, if item exists;
   $self->load_options;        # load options -- need to do after loading item
   $self->dump_fields if $self->verbose;
   return;
}

=head2 process

For persistent FormHandler instances, processes a form

   my $validated = $form->process( item => $book, 
       params => $c->req->parameters );

or:

   my $validated = $form->process( item_id => $item_id,
       schema => $schema, params => $c->req->parameters );

Calls 'clear' to clear previous values, calls 'update' to process the form.
$self->dump_fields if $self->verbose;
If you set attributes that are not cleared and you have a persistent form,
you must either set that attribute on each request or clear it.

If your form is not persistent, you should call 'update' instead, because 
this method clears the schema, item and item_id.

This method can also be used for non-database forms:

    $form->process( params => $params );

=cut 

sub process
{
   my ( $self, @args ) = @_;
   $self->clear;
   return $self->update(@args);
}

=head2 clear

Calls clear_state, clear_model (in the model), and clears 'ctx'

=cut

sub clear
{ 
   my $self = shift;
   warn "HFH: clear ", $self->name, "\n" if $self->verbose;
   $self->clear_state;
   $self->clear_params;
   $self->clear_model if $self->can('clear_model');
   $self->ctx(undef) if $self->ctx;
}

=head2 update

This is the method to call to update the form if your form is not persistent.
Pass in item or item_id/schema and parameters. 

    my $form = MyApp::Form::Book->new;
    $form->update( item => $item, schema => $schema );

=cut

sub update
{
   my ( $self, @args ) = @_;
   my $hashref = {@args};
   while ( my ($key, $value) = each %{$hashref} )
   {
      $self->$key($value);
   } 
   warn "HFH: update ", $self->name, "\n" if $self->verbose;
   $self->init_from_object;
   $self->load_options;
   my $validated = $self->validate if $self->has_params;
   $self->update_model if ( $validated && $self->can('update_model') );
   $self->dump_fields if $self->verbose;
   return $validated;
}

=head2 clear_state

Clears out state information in the form.  

   validated
   ran_validation
   num_errors
   updated_or_created
   fields: value, input, fif, errors   
   params

=cut

sub clear_state
{
   my $self = shift;
   $self->validated(0);
   $self->ran_validation(0);
   $self->num_errors(0);
   $self->clear_values; 
   $self->updated_or_created(undef);
}

=head2 clear_values

Clears field value, input, errors

=cut

sub clear_values
{
   my $self = shift;
   for ( $self->fields )
   {
      $_->value(undef);
      $_->input(undef);
      $_->clear_errors;
   }
}


=head2 dump_fields

Dumps the fields of the form for debugging.

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

=head2 init_from_object

Populates the field 'value' attributes from $form->item
by calling a form's custom init_value_$fieldname method, passing in
the field and the item. If a custom init_value_ method doesn't exist,
uses the generic 'init_value' routine from the model.

The value is stored in both the 'init_value' attribute, and the 'value'
attribute.

=cut

sub init_from_object
{
   my $self = shift;

   $self->item( $self->build_item ) if $self->item_id && !$self->item;
   my $item = $self->init_object || $self->item || return;
   warn "HFH: init_from_object ", $self->name, "\n" if $self->verbose;
   for my $field ( $self->fields )
   {
      my @values;
      my $method = 'init_value_' . $field->name;
      if ( $self->can($method) )
      {
         @values = $self->$method( $field, $item );
      }
      else
      {
         @values = $self->init_value( $field, $item );
      }
      my $value = @values > 1 ? \@values : shift @values;

      # Handy for later compare
      $field->init_value($value);
      $field->value($value);
   }
}


=head2 fif  (fill in form)

Returns a hash of values suitable for use with HTML::FillInForm
or for filling in a form with C<< $form->fif->{fieldname} >>.

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
      $params->{ $prefix . $field->name } = $field->fif;
   }
   return $params;
}

=head2 sorted_fields

Calls fields and returns them in sorted order by their "order"
value.

=cut

sub sorted_fields
{
   my $form = shift;

   my @fields = sort { $a->order <=> $b->order } $form->fields;
   return wantarray ? @fields : \@fields;
}

=head2 field NAME

Searches for and returns a field named "NAME".
Dies on not found.

    my $field = $form->field('first_name');

Pass a second true value to not die on errors.
 
    my $field = $form->field('something', 1 );

=cut

sub field
{
   my ( $self, $name, $no_die ) = @_;

   $name = $self->name_prefix . '.' . $name if $self->name_prefix;
   for my $field ( $self->fields )
   {
      return $field if $field->name eq $name;
   }
   return if $no_die;
   croak "Field '$name' not found in form '$self'";
}

sub field_index
{
   my ( $self, $name ) = @_;
   $name = $self->name_prefix . '.' . $name if $self->name_prefix;
   my $index = 0;
   for my $field ( $self->fields )
   {
      return $index if $field->name eq $name;
      $index++;
   }
   return;
}

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


=head2 validate

This method is called by the 'update' method. It might be called
by itself for a non-database form (although 'process' will also work).

   my $validated = $form->validate( $params );

Validates the form from the HTTP request parameters.
The parameters must be a hash ref with multiple values as array refs.

Returns false if validation fails.

Params may be passed in to validate, or else may be set earlier
on new, or by using the params setter.

The method does the following:
 
    1) sets required dependencies
    2) trims params and saves in field 'input' attribute
    3) calls the field's 'validate_field' routine which:
        1) validates that required fields have a value
        2) calls the field's 'validate' routine (the one that is provided
           by custom field classes)
        3) calls 'input_to_value' to move the data from the 'input' attribute 
           to the 'value' attribute if it hasn't happened already in 'validate'
    4) calls the form's validate_$fieldname, if the method exists and
       if there's a value in the field
    5) calls cross_validate for validating fields that might be blank and
       checking more complex dependencies. (If this field, then not that field...) 
    6) calls the model's validation method. By default, this only checks for
       database uniqueness.
    7) counts errors, sets 'ran_validation' and 'validated' flags
    8) returns 'validated' flag


=cut

sub validate
{
   my ( $self, $params ) = @_;

   $self->clear_state; 
   warn "HFH: validate ", $self->name, "\n" if $self->verbose;

   # Set params 
   $self->params($params) if (ref $params eq 'HASH');
   $params = $self->params; 
   return unless $self->has_params;
   $self->set_dependency;    # set required dependencies

   foreach my $field ( $self->fields )
   {
      # Trim values and move to "input" slot
      $field->input( $field->trim_value( $params->{$field->full_name} ) );
      next if $field->clear;    # Skip validation
      # Validate each field and "inflate" input -> value.
      $field->validate_field;
      next unless defined $field->value;
      # these methods have access to the inflated values
      my $field_name = $field->name;
      my $prefix     = $self->name_prefix;
      $field_name =~ s/^$prefix\.//g if $prefix;
      my $method = 'validate_' . $field_name;
      $self->$method($field) if $self->can($method);
      if ( $self->verbose )
      {
         my $field_validated = $field->has_errors ? 'has errors' : 'validated';
      }
   }

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

   
   return $self->validated;
}

=head2 munge_params

Munges the parameters when they are set.  Currently just adds 
keys without the "html_prefix". Can be subclassed.

=cut

sub munge_params
{
   my ( $self, $params ) = @_;
   if ( $self->html_prefix )
   {
      my $prefix = $self->name;
      while ( ( my $key, my $value ) = each %$params )
      {
         ( my $new_key = $key ) =~ s/^$prefix\.//g;
         if ( $new_key ne $key )
         {
            $params->{$new_key} = $value;
         }
      }
   }
}

=head2 dump_validated

For debugging, dump the validated fields.

=cut

sub dump_validated
{
   my $self = shift;
   warn "HFH: fields validated:\n";
   warn "HFH: ", $_->name, ": ", ( $_->has_errors ? join( ' | ', $_->errors ) : 'validated' ), "\n"
      for $self->fields;
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

=head2 error_field_name

Returns the names of the fields with errors.

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

Generates a hidden html field with a unique ID which
the model class can use to check for duplicate form postings.

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

=head2 build_form

This parses the form field_list and creates the individual
field objects.  It calls the make_field() method for each field.
This is called by the BUILD method. Users don't need to call this.

=cut

sub build_form
{
   my $self = shift;
  
   my $meta_flist = $self->meta->field_list if $self->meta->can('field_list');
   my $flist = $self->field_list;
   $self->_build_fields( $meta_flist, 0 ) if $meta_flist; 
   $self->_build_fields( $flist->{'required'}, 1 ) if $flist->{'required'}; 
   $self->_build_fields( $flist->{'optional'}, 0 ) if $flist->{'optional'};
   $self->_build_fields( $flist->{'fields'}, 0 )   if $flist->{'fields'};
   $self->_build_fields( $flist->{'auto_required'}, 1, 'auto' ) 
                                              if $flist->{'auto_required'};
   $self->_build_fields( $flist->{'auto_optional'}, 0, 'auto' ) 
                                              if $flist->{'auto_optional'};
   return unless $self->has_fields;
   my $order = 0;
   foreach my $field ( $self->fields)
   {
      $order++ if $field->order > $order;
   }
   $order++;
   foreach my $field ( $self->fields )
   {
      $field->order( $order ) unless $field->order;
      $order++;
   }

}

sub _build_fields
{
   my ( $self, $fields, $required, $auto ) = @_;

   return unless $fields;
   my $field;
   my $name;
   my $type;
   if ($auto)    # an auto array of fields
   {
      foreach $name (@$fields)
      {
         $type = $self->guess_field_type($name);
         croak "Could not guess field type for field '$name'" unless $type;
         $self->_set_field( $name, $type, $required );
      }
   }
   elsif ( ref($fields) eq 'ARRAY' )    # an array of fields
   {
      while (@$fields)
      {
         $name = shift @$fields;
         $type = shift @$fields;
         $self->_set_field( $name, $type, $required );
      }
   }
   else                                 # a hashref of fields
   {
      while ( ( $name, $type ) = each %$fields )
      {
         $self->_set_field( $name, $type, $required );
      }
   }
   return;
}

sub _set_field
{
   my ( $self, $name, $type, $required ) = @_;

   my $field = $self->make_field( $name, $type );
   return unless $field;
   $field->required($required) unless ( $field->required == 1 );
   my $index = $self->field_index($name);
   if( defined $index )
      { $self->set_field_at($index, $field); }
   else
      { $self->add_field($field); }
}

=head2 make_field

    $field = $form->make_field( $name, $type );

Maps the field type to a field class, creates a field object and
and returns it.

The "$name" parameter is the field's name (e.g. first_name, age).

The second parameter is either a scalar which is the field's type
string, or a hashref with a 'type' key containing the field's type.

=cut

sub make_field
{
   my ( $self, $name, $attr ) = @_;

   $attr = { type => $attr } unless ref $attr eq 'HASH';
   my $type = $attr->{type} ||= 'Text';
   my $class =
        $type =~ s/^\+//
      ? $self->field_name_space
         ? $self->field_name_space . "::" . $type
         : $type
      : 'HTML::FormHandler::Field::' . $type;
   $class->require
      or die "Could not load field class '$type' for field '$name'"; 

   # Add field name and reference to form 
   $attr->{name} =
        $self->name_prefix
      ? $self->name_prefix . '.' . $name
      : $name;
   $attr->{form} = $self;
   my $field = $class->new( %{$attr} );
   return $field;
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
   my $self = shift;

   warn "HFH: load_options ", $self->name, "\n" if $self->verbose;
   $self->load_field_options($_) for $self->fields;
}

=head2 load_field_options

Load the options array into a field. Pass in a field object,
and, optionally, an options array.

=cut

sub load_field_options
{
   my ( $self, $field, @options ) = @_;

   return unless $field->can('options');

   my $method = 'options_' . $field->name;
   @options =
        $self->can($method)
      ? $self->$method($field)
      : $self->lookup_options($field)
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

   $_->required(0) for $self->required;
   $self->clear_required;
}

=head1 AUTHOR

Gerda Shank, gshank@cpan.org

Based on the original source code of L<Form::Processor> by Bill Moseley

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose;
1;
