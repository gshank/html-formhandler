package HTML::FormHandler::Field;

use HTML::FormHandler::Moose;
use MooseX::AttributeHelpers;
use HTML::FormHandler::I18N;    # only needed if running without a form object.

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

A number of field classes are provided by the distribution. The basic
field types are:

   Text
   Integer
   Select
   Boolean

These field types alone would be enough for most applications, since
the equivalent of the others could be defined using field attributes,
custom validation methods, and applied actions.  There is some benefit 
to having descriptive names, of course, and if you have multiple fields  
requiring the same validation, defining a custom field class may be a
good idea.

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
this attribute to provide the name of accessor.

=item full_name

The name of the field with all parents:

   'event.start_date.month'

=item html_name

The full_name plus the form name if 'html_prefix' is set.

=back

=head2 Field data

=over

=item input

The input string from the parameters passed in.

=item value

The value as it would come from or go into the database, after being
acted on by transforms. Used to construct the C<< $form->values >>
hash. Validation and constraints act on 'value'.

=item fif

Values used to fill in the form. Read only.

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
name and provide a C<< 'widget_<name>' >> method in Render::Simple
or a widget template if you are using a template based rendering
system. (see L<HTML::FormHandler::Manual::Templates>) 

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

The default widget is 'text'.

=head2 Flags

   password  - prevents the entered value from being displayed in the form
   writeonly - The initial value is not taken from the database
   clear     - Always set the database column to null.
   noupdate  - Do not update this field in the database

=head2 Form methods for fields

These provide the name of a method in a form (not the field ) which will act 
on a particular field.

=over

=item set_validate

Specify a form method to be used to validate this field.
The default is C<< 'validate_' . $field->name >>. (Periods in

   has_field 'title' => ( isa => 'Str', set_validate => 'check_title' );
   has_field 'subtitle' => ( isa => 'Str', set_validate => 'check_title' );

=item set_init

The name of the method in the form that provides a field's initial value
 
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

=head2 deflation

A coderef that will convert from an inflated value back to a flat
data representation suitable for displaying in an HTML field 

   has_field 'my_date_time' => ( 
      type => 'Compound',
      apply => [ { transform => sub{ DateTime->new( $_[0] ) } } ],
      deflation => sub { { year => $_->year, month => $_->month, day => $_->day } },
      fif_from_value => 1,
   );
   has_field 'date_time_fif.year' => ( fif_from_value => 1 );
   has_field 'date_time_fif.month';
   has_field 'date_time_fif.day' => ( fif_from_value => 1 );

=head1 Processing and validating the field

=head2 validate_field

This method does standard validation, which currently tests:

    required        -- if field is required and value exists

If these tests pass, the field's validate method is called

    $field->validate;

If C<< $field->validate >> returns true then the input value
is copied from the input attribute to the field's value attribute.

The field's error list and internal value are reset upon entry.

=head2 validate

This field method can be used in addition to or instead of 'apply' actions
in custom field classes. It is not called if the field already has errors.
It should validate the field data and returns true if
the data validates.  An error message must be added to the field with
C<< $field->add_error( ... ) >> if the value does not validate. 

    sub validate {
        my $field = shift;
        my $value = $field->value;
        return $field->add_error( ... ) if ( ... );
        return 1;
    }

=cut

has 'name' => ( isa => 'Str', is => 'rw', required => 1 );
has 'type' => ( isa => 'Str', is => 'rw', default => sub { ref shift } );
has 'init_value' => ( is => 'rw', clearer  => 'clear_init_value');
has 'value' => (
   is        => 'rw',
   clearer   => 'clear_value',
   predicate => 'has_value',
);
has 'parent' => ( is => 'rw', predicate => 'has_parent' );
has 'errors_on_parent' => ( isa => 'Bool', is => 'rw' );
sub has_fields { }
has 'input' => (
   is        => 'rw',
   clearer   => 'clear_input',
   predicate => 'has_input',
);
has 'input_without_param' => (
   is        => 'rw',
   predicate => 'has_input_without_param'
);
has 'fif' => ( 
    is => 'rw', 
    clearer => 'clear_fif', 
    predicate => 'has_fif',
    lazy_build => 1,
);
has 'fif_from_value' => ( isa => 'Str', is => 'rw',
    clearer => 'clear_fif_from_value');
sub _build_fif {
   my $self = shift;

   return if( defined $self->password && $self->password == 1 );
   if ( $self->has_input && !$self->fif_from_value )
   {
      return $self->input;
   }
   my $parent = $self->parent;
   if ( defined $parent &&
      $parent->isa('HTML::FormHandler::Field') &&
      $parent->has_deflation &&
      ref $parent->fif eq 'HASH' &&
      exists $parent->fif->{ $self->name } )
   {
      return $self->_apply_deflation( $parent->fif->{ $self->name } );
   }
   if ( defined $self->value )
   {
      return $self->_apply_deflation( $self->value );
   }
   if ( $self->fif_from_value )
   {
      return $self->input;
   }
   return;
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
has 'title' => ( isa => 'Str', is => 'rw' );
has 'style' => ( isa => 'Str', is => 'rw' );
has 'css_class' => ( isa => 'Str', is => 'rw' );
# should we remove/deprecate this?
has 'sub_form' => ( isa => 'HTML::FormHandler', is => 'rw' );
has 'form' => ( isa => 'HTML::FormHandler', is => 'rw', weak_ref => 1 );
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
has 'widget' => ( isa => 'Str', is => 'rw', default => 'text' );
has 'order' => ( isa => 'Int', is => 'rw', default => 0 );
has 'required' => ( isa => 'Bool', is => 'rw', default => '0' );
has 'required_message' => (
   isa     => 'Str',
   is      => 'rw',
   lazy    => 1,
   default => sub { shift->label . ' field is required' }
);
has 'unique' => ( isa => 'Bool', is => 'rw' );
has 'unique_message' => ( isa => 'Str', is => 'rw' );
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
has 'id' => ( isa => 'Str', is => 'rw', lazy => 1, builder => 'build_id' );
sub build_id
{
   my $field = shift;
   my $form_name = $field->form ? $field->form->name : 'fld-';
   return $form_name . $field->name;
}
has 'javascript' => ( isa => 'Str', is => 'rw' );
has 'password' => ( isa => 'Bool', is => 'rw' );
has 'writeonly' => ( isa => 'Bool', is => 'rw' );
has 'clear' => ( isa => 'Bool', is => 'rw' );
has 'disabled' => ( isa => 'Bool', is => 'rw' );
has 'readonly' => ( isa => 'Bool', is => 'rw' );
has 'noupdate' => ( isa => 'Bool', is => 'rw' );
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
      unless $self->form
         && $self->set_init
         && $self->form->can( $self->set_init );
   return 1;
}
sub _init_value
{
   my $self = shift;
   return unless $self->_can_init_value;
   my $meth = $self->set_init;
   $self->form->$meth($self, $self->form->item);
}
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
has 'deflation' => (
   is         => 'rw',
   predicate  => 'has_deflation',
);
has 'trim' => ( isa => 'HashRef', is => 'rw', 
   default => sub {{ 
      transform => 
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
      },
   }}
);


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
               foreach my $apply_def ( @{ $role->apply_list} )
               {
                  my %new_apply = %{$apply_def}; # copy hashref
                  push @apply_list, \%new_apply; 
               }
            }
         }
      }
      if ( $meta->can('apply_list') && $meta->has_apply_list )
      {
         foreach my $apply_def ( @{ $meta->apply_list} )
         {
            my %new_apply = %{$apply_def}; # copy hashref
            push @apply_list, \%new_apply; 
         }
      }
   }
   $self->add_action( @apply_list );
}

sub _init { }

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

sub validate_field
{
   my $field = shift;

   $field->clear_errors;
   # See if anything was submitted
   if( !$field->has_input || !$field->input_defined )
   {
      if( $field->required )
      {
         $field->add_error( $field->required_message ) if ( $field->required );
         $field->value(undef)                          if ( $field->has_input );
         return;
      }
      elsif ( !$field->has_input )
      {
         return;
      }
      elsif( !$field->input_defined )
      {
         $field->value(undef);
         return;
      }
   }
   else
   {
      $field->clear_value;
      $field->value( $field->input );
   }

   $field->_inner_validate_field;
   # do building of node 
   $field->build_node;

   $field->_apply_actions;

#   $field->_build_fif if $field->can('_build_fif');
   return unless $field->validate;
   return if $field->has_errors;
   return unless $field->test_ranges;

   return !$field->has_errors;
}
sub _inner_validate_field { }
sub build_node { }

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
      # the first time through value == input
      my $value = $self->value;
      my $new_value = $value;
      # Moose constraints 
      if ( !ref $action || ref $action eq 'MooseX::Types::TypeDecorator' )
      {
         $action = { type => $action };
      }
      if ( exists $action->{type} )
      {
         my $tobj;
         if( ref $action->{type} eq 'MooseX::Types::TypeDecorator' )
         {
            $tobj = $action->{type};
         }
         else
         {
            my $type = $action->{type};
            $tobj = Moose::Util::TypeConstraints::find_type_constraint($type)
               or die "Cannot find type constraint $type";
         }
         if ( $tobj->has_coercion && $tobj->validate($value) )
         {
            eval { $new_value = $tobj->coerce($value) };
            if ($@)
            {
               if ( $tobj->has_message )
               {
                  $error_message = $tobj->message->($value);
               }
               else
               {
                  $error_message = $@;
               }
            }
            else
            {
               $self->value($new_value);
            }
            
         }
         $error_message ||= $tobj->validate($new_value);
      }
      # now maybe: http://search.cpan.org/~rgarcia/perl-5.10.0/pod/perlsyn.pod#Smart_matching_in_detail
      # actions in a hashref
      elsif ( ref $action->{check} eq 'CODE' )
      {
         if ( !$action->{check}->($value) )
         {
            $error_message = 'Wrong value';
         }
      }
      elsif ( ref $action->{check} eq 'Regexp' )
      {
         if ( $value !~ $action->{check} )
         {
            $error_message = "\"$value\" does not match";
         }
      }
      elsif ( ref $action->{check} eq 'ARRAY' )
      {
         if ( !grep { $value eq $_ } @{ $action->{check} } )
         {
            $error_message = "\"$value\" not allowed";
         }
      }
      elsif ( ref $action->{transform} eq 'CODE' )
      {
         $new_value = eval { 
            no warnings 'all';
            $action->{transform}->($value);
         };
         if ($@)
         {
            $error_message = $@ || 'error occurred';
         }
         else
         {
            $self->value($new_value);
         }
      }
      if ( defined $error_message )
      {
         my @message = ($error_message);
         if ( defined $action->{message} )
         {
            my $act_msg = $action->{message};
            if ( ref $act_msg eq 'CODEREF' )
            {
               $act_msg = $act_msg->($value); 
            }
            if ( ref $act_msg eq 'ARRAY' )
            {
               @message = @{ $act_msg };
            }
            elsif ( ref \$act_msg eq 'SCALAR' )
            {
               @message = ( $act_msg );
            }
         }
         $self->add_error(@message);
      }
   }
}

sub _apply_deflation
{
   my ( $self, $value )  = @_;

   if( $self->has_deflation )
   {
      $value = $self->deflation->($value);
   }
   return $value;
}

sub validate { 1 }

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

# use Class::MOP to clone 
sub clone
{
   my ( $self, %params ) = @_;
   $self->meta->clone_object($self, %params);
}

sub clear_data
{
   my $self = shift;
   $self->clear_input;
   $self->clear_value;
   $self->clear_fif;
   $self->clear_errors;
   $self->clear_init_value;
   $self->clear_fif_from_value;
   $self->clear_other;
}
sub clear_other { }

# removed pod to discourage use of fif_value
# This method will probably be replaced by deflate or something
# similar in the near future
sub fif_value
{
   my ( $self, $value ) = @_;
   return $value;
}

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

sub required_text { shift->required ? 'required' : 'optional' }

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
