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
use Scalar::Util qw(blessed);


use 5.008;

our $VERSION = '0.23';

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


=head1 ATTRIBUTES and METHODS

=head2 Creating a form with 'new' 

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

=head2 Processing the form

There are three different methods to call to process the form,
depending on whether it is persistent or not, and whether or
not it is a database form.

'process' should always work. 'update' or 'validate' may avoid
certain amounts of unnecessary processing.

=head3 process

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

=head3 update

This is the method to call to update the form if your form is not persistent.
Pass in item or item_id/schema and parameters. 

    my $form = MyApp::Form::Book->new;
    $form->update( item => $item, schema => $schema );

It set attributes from the parameters passed in, initializes values,
loads select options, calls validate if there are parameters, and calls
update_model if the form validated.  It returns the 'validated' flag.

=head3 validate

This is the non-database form processing method.

  $self->validate( $params );

or

 $self->validate( key => 'something', params => $params );

It will call the validate_form method to perform validation
on the fields.

=head3 Clear form state

   clear - clears state, params, model, ctx
   clear_state - clears flags, errors, and params
   clear_values, clear_errors, clear_fif - on all fields

=head2 Getting data out

=head3 fif  (fill in form)

Returns a hash of values suitable for use with HTML::FillInForm
or for filling in a form with C<< $form->fif->{fieldname} >>.
The fif value for a 'title' field in a TT form:

   [% form.fif.title %] 

=head3 values

Returns a hashref of all field values. Useful for non-database forms.
The 'fif' and 'values' hashrefs will be the same unless there's a
difference in format between the HTML field values (in fif) and the saved value
or unless the field 'name' and 'accessor' are different. 'fif' returns
a hash with the field names for the keys and the field's 'fif' for the
values; 'values' returns a hash with the field accessors for the keys, and the
field's 'value' for the the values. 

=head2 Accessing and setting up fields

=head3 has_field

The most common way of declaring fields is the 'has_field' syntax.
See L<HTML::FormHandler::Manual::Intro>

=head3 field_list

A hashref of field definitions which can be used as an
alternative to 'has_field' in small, dynamic forms.

    field_list => {
        fields => [
            field_one => {
               type => 'Text',
               required => 1
            },
            field_two => 'Text,
         ],
     } 


=head3 field_name_space

Use to set the name space used to locate fields that 
start with a "+", as: "+MetaText". Fields without a "+" are loaded
from the "HTML::FormHandler::Field" name space. If 'field_name_space'
is not set, then field types with a "+" must be the complete package
name.

=head3 field($name)

This is the method that is usually called in your templates to
access a field:

    [% f = form.field('title') %]

Searches for and returns a field named "NAME".
Dies on not found.

    my $field = $form->field('first_name');

Pass a second true value to not die on errors.
 
    my $field = $form->field('something', 1 );

=head3 value($name)

Convenience function to return the value of the field. Returns
undef if field not found.


=head2 Accessing errors 

  has_errors - returns true or false
  error_fields - returns list of fields with errors
  errors - returns array of error messages for the entire form
  num_errors - number of errors in form


=head2 name

The form's name.  Useful for multiple forms.
It used to construct the default 'id' for fields, and is used
for the HTML field name when 'html_prefix' is set. 
The default is "form" + a one to three digit random number.

=head2 init_object

If an 'init_object' is supplied on form creation, it will be used instead 
of the 'item' to pre-populate the values in the form. This can be useful 
when populating a form from default values stored in a similar but different 
object than the one the form is creating. The 'init_object' should be either
a hash or the same type of object that the model uses (a DBIx::Class row for
the DBIC model).

=head2 Validation flags

=head3 ran_validation

Flag to indicate that validation has been run. This flag will be
false when the form is initially loaded and displayed, since
validation is not run until FormHandler has params to validate.
It normally shouldn't be necessary for users to check this flag.

=head3 validated

Flag that indicates if form has been validated. If you're using the
'update', 'process', or 'validate' methods, you many not 
need to use this flag, since the return value of those methods 
is this flag. You might want to use this flag if you've
written a method to replace 'update' or 'process', or you're
doing something in between update/validate, such as set a stash key.

   $form->update( ... );
   $c->stash->{...} = ...;
   return unless $form->validated;

=head3 verbose

Flag to print out additional diagnostic information. See 'dump_fields' and
'dump_validated'.

=head2 ctx

Place to store application context

=head2 language_handle, build_language_handle

Holds a Local::Maketext language handle

The builder for this attribute gets the Locale::Maketext language 
handle from the environment variable $ENV{LANGUAGE_HANDLE}, or creates 
a default language handler using L<HTML::FormHandler::I18N>

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

Also see the Field attribute "html_name", a convenience function which
will return the form name + "." + field name

=head2 active_column

The column in tables used for select list that marks an option 'active'.
You might use this if all of your tables have the same 'active' column
name, instead of setting this for each field.

=head2 For use in HTML
 
   http_method - For storing 'post' or 'get'
   action - Store the form 'action' on submission. No default value.
   submit - Store form submit field info. No default value.
   uuid - generates a string containing an HTML field with UUID

=head2 params

Stores HTTP parameters. 
Also: set_param, get_param, clear_params, delete_param, 
has_params from Moose 'Collection::Hash' metaclass. 

The 'set_param' method could be used to add additional field
input that doesn't come from the HTML form, similar to a hidden field:

   my $form = MyApp::Form->new( $item, $params );
   $form->set_param('comment', 'updated by edit form');
   return unless $form->update;

(Note: 'process' clears params, so you have to use 'update' ); 

=head2 dependency

Arrayref of arrayrefs of fields. If one of a group of fields has a
value, then all of the group are set to 'required'.

  has '+dependency' => ( default => sub { [
     ['street', 'city', 'state', 'zip' ],] }
  );

=head2 cross_validate

This method is useful for cross checking values after they have been saved 
as their final validated value, and for performing more complex dependency
validation.

This method is called even if some fields did not validate.

=cut

has 'name' => (
   isa     => 'Str',
   is      => 'rw',
   default => sub { return 'form' . int( rand 1000 ) }
);
# for consistency in api with field nodes
has 'form' => ( isa => 'HTML::FormHandler', is => 'rw', weak_ref => 1,
   lazy => 1, default => sub { shift });
has 'parent' => ( is => 'rw' );
# object with which to initialize
has 'init_object' => ( is => 'rw' );
# flags
has [ 'ran_validation', 'validated', 'verbose' ] => ( isa => 'Bool', is => 'rw' );
has 'user_data' => ( isa => 'HashRef', is => 'rw' );
has 'ctx' => ( is => 'rw', weak_ref => 1, clearer => 'clear_ctx' );
# for Locale::MakeText
has 'language_handle' => (
   is      => 'rw',
   builder => 'build_language_handle'
);
has 'num_errors' => ( isa => 'Int', is => 'rw', default => 0 );
has 'html_prefix' => ( isa => 'Bool', is => 'rw' );
has 'active_column' => ( isa => 'Str', is => 'rw' );
has 'http_method' => ( isa => 'Str', is => 'rw', default => 'post' );
has 'action' => ( is => 'rw' );
has 'submit' => ( is => 'rw' );
has 'params' => (
   metaclass  => 'Collection::Hash',
   isa        => 'HashRef',
   is         => 'rw',
   default    => sub { {} },
   auto_deref => 1,
   trigger    => sub { shift->_munge_params(@_) },
   provides   => {
      set    => 'set_param',
      get    => 'get_param',
      clear  => 'clear_params',
      delete => 'delete_param',
      empty  => 'has_params',
   },
);
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
has 'field_list' => ( is => 'rw', default => sub { {} } );
sub has_field_list
{
   my $self = shift;
   if( ref $self->field_list eq 'HASH' )
   {
      return 1 if( scalar keys %{$self->field_list} );
   }
   elsif( ref $self->field_list eq 'ARRAY' )
   {
      return 1 if( scalar @{$self->field_list} );
   }
   return;
}
has 'field_name_space' => (
   isa     => 'Str|Undef',
   is      => 'rw',
   default => '',
);


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

   $self->_build_fields;    # create the form fields
   return if defined $self->item_id && !$self->item;
   $self->_init_from_object;    # load values from object, if item exists;
   $self->_load_options;        # load options -- need to do after loading item
   $self->dump_fields if $self->verbose;
   return;
}

sub build_language_handle
{
   my $lh = $ENV{LANGUAGE_HANDLE}
      || HTML::FormHandler::I18N->get_handle
      || die "Failed call to Locale::Maketext->get_handle";
   return $lh;
}

sub process
{
   my ( $self, @args ) = @_;
   $self->clear;
   return $self->update(@args);
}

sub update
{
   my ( $self, @args ) = @_;

   warn "HFH: update ", $self->name, "\n" if $self->verbose;
   $self->_setup_form(@args);
   $self->validate_form if $self->has_params;
   $self->update_model if $self->validated;
   $self->dump_fields if $self->verbose;
   return $self->validated;
}

sub validate
{
   my ( $self, @args ) = @_;

   warn "HFH: validate ", $self->name, "\n" if $self->verbose;
   $self->clear_state;
   $self->clear_values;
   $self->_setup_form( @args );
   return unless $self->has_params;
   return $self->validate_form;
}

sub db_validate
{
   my $self = shift;
   foreach my $field ($self->fields)
   {
      $self->set_param( $field->full_name, $field->fif );
   }
   return $self->validate;
}

sub clear
{ 
   my $self = shift;
   warn "HFH: clear ", $self->name, "\n" if $self->verbose;
   $self->clear_state;
   $self->clear_params;
   $self->clear_model;
   $self->clear_ctx;
}

sub clear_state
{
   my $self = shift;
   $self->validated(0);
   $self->ran_validation(0);
   $self->num_errors(0);
   $self->clear_errors;
   $self->clear_fif;
}

sub clear_fif { shift->clear_fifs }

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

sub value
{
   my ( $self, $fieldname ) = @_;
   my $field = $self->field( $fieldname, 1 ) || return;
   return $field->value; 
}

sub cross_validate { 1 }

# deprecated
sub has_error
{
   my $self = shift;
   return $self->ran_validation && !$self->validated;
}

sub has_errors
{
   for ( shift->fields )
   {
      return 1 if $_->has_errors;
   }
   return 0;
}

sub error_fields
{
   return grep { $_->has_errors } shift->sorted_fields;
}

# deprecated?
sub error_field_names
{
   my $self         = shift;
   my @error_fields = $self->error_fields;
   return map { $_->name } @error_fields;
}

sub errors
{
   my $self         = shift;
   my @error_fields = $self->error_fields;
   return map { $_->errors } @error_fields;
}

sub uuid
{
   my $form = shift;
   require Data::UUID;
   my $uuid = Data::UUID->new->create_str;
   return qq[<input type="hidden" name="form_uuid" value="$uuid">];
}

sub validate_form
{
   my $self = shift;
   my $params = $self->params; 
   $self->_set_dependency;    # set required dependencies
   foreach my $field ( $self->fields )
   {
      # Trim values and move to "input" slot
      if ( exists $params->{$field->full_name} )
      {
         $field->input( $params->{$field->full_name} )
      }
      elsif ( $field->has_input_without_param )
      {
         $field->input( $field->input_without_param );
      }
   }

   $self->_fields_validate;
      
   $self->cross_validate($params);
   # model specific validation 
   $self->validate_model;
   $self->_clear_dependency;

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

sub _setup_form
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
   $self->_init_from_object;
   $self->_load_options;
}

sub _init_from_object
{
   my ( $self, $node, $item ) = @_;
   $node ||= $self;
   $self->item( $self->build_item ) if $self->item_id && !$self->item;
   $item ||= $self->init_object || $self->item || return;
   warn "HFH: init_from_object ", $self->name, "\n" if $self->verbose;
   for my $field ( $node->fields )
   {
      next if $field->parent && $field->parent != $node;
      next if ref $item eq 'HASH' && !exists $item->{$field->accessor};
      my $value = $self->_get_value( $field, $item );
      $value = $field->_apply_deflations( $value );
      if( $field->isa( 'HTML::FormHandler::Field::Compound' ) ){
         $self->_init_from_object( $field, $value );
      }
      else{
         if ( $field->_can_init )
         {
            my @values;
            @values = $field->_init( $field, $item );
            my $value = @values > 1 ? \@values : shift @values;
            $field->init_value($value) if $value;
            $field->value($value) if $value;
         }
         else
         {
            $self->init_value( $field, $value );
         }
      }
   }
}

sub _get_value
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
   return $value;
}

sub init_value
{
   my ( $self, $field, $value ) = @_;
   $field->init_value($value);
   $field->value($value);
}

sub _load_options
{
   my ( $self, $node, $model_stuff ) = @_;

   $node ||= $self;
   warn "HFH: load_options ", $node->name, "\n" if $self->verbose;
   for my $field ( $node->fields ){
       if( $field->isa( 'HTML::FormHandler::Field::Compound' ) ){
           my $new_model_stuff = $self->compute_model_stuff( $field, $model_stuff );
           $self->_load_options( $field, $new_model_stuff );
       }
       else {
           $self->_load_field_options($field, $model_stuff);
       }
   }
}

sub _load_field_options
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

sub _set_dependency
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
         my $field = $self->field($name);
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

sub _clear_dependency
{
   my $self = shift;

   $_->required(0) for $self->_required;
   $self->clear_required;
}

sub _munge_params
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

HTML::FormHandler->meta->make_immutable;
no Moose;
1;
