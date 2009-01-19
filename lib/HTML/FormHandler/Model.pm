package HTML::FormHandler::Model;

use Moose;
use Carp;
use Data::Dumper;

=head1 NAME

HTML::FormHandler::Model - default model base class

=head1 SYNOPSIS

This class defines the base attributes for FormHandler model
classes. It is not used directly.

=head1 DESCRIPTION

This is an empty base class that defines methods called by
HTML::FormHandler to support interfacing forms with a data store
such as a database.

This module provides instructions on methods to override to create
a HTML::FormHandler::Model class to work with a specific object relational
mapping (ORM) tool.

For an example see L<HTML::FormHandler::Model::CDBI> for working with
the Class::DBI ORM.

=head1 METHODS

=head2 item, build_item

The "item" is initialized with "build_item" the first time $form->item is called.  
"item" must be defined in the model class to fetch the object based on the item id.
It should return the item's object.  Column values are fetched and updated
by calling methods on the returned object.

For example, with Class::DBI you might return:

    return $self->item_class->retrieve( $self->item_id );

=cut

has 'item' => (
   is      => 'rw',
   lazy    => 1,
   builder => 'build_item',
   trigger => sub { shift->set_item(@_) }
);
sub build_item  { return }
sub set_item 
{ 
   my ( $self, $item) = @_;
   $self->item_class( ref $item ); 
}

=head2 item_id

The id (primary key) of the item (object) that the form is updating
or has just created. The model class should have a build_item method that can
fetch the object from the item_class for this id.

=cut

has 'item_id' => ( is => 'rw' );

=head2 item_class

"item_class" sets and returns a value used by the model class to access
the ORM class related to a form.

For example, if the model class interfaces with Class::DBI and
a form is created for updating, say, MyDB::Users then in your form
class:

    sub item_class { 'MyDB::Users' }

This gives the model class a way to access the data store.
If this is not a fixed value (as above) then do not define the
method in your subclass and instead set the value when the form
is created:

    my $form = MyApp::Form::Users->new;
    $form->item_class( $my_object );

The value can be any scalar (or object) needed by the specific ORM
to access the data related to the form.

This method does not need to be defined in a model subclass unless
you wish to do extra validation.

The default returns the class of "item", if item is defined.  It's not as useful
as it sounds because "item" doesn't exist when creating new records.

This can also be set as a parameter to new, but will be overridden in subclasses.

=cut

has 'item_class' => (
   isa     => 'Str',
   is      => 'rw',
);

# tell Moose to make this class immutable
HTML::FormHandler::Model->meta->make_immutable;

=head2 guess_field_type

Returns the guessed field type.  The field name is passed as the first argument.
This is only required if using "Auto" type of fields in your form classes.

The default is to die, since we can't guess.  To be useful this must be
overridden in a form model class.  You could override this in your form class, for
example, if you use a field naming convention that indicates the field type.

HTML::FormHandler::Model::CDBI uses CDBI's meta_info() method to look at
relationships and figure out the field type.  Other form model classes might
look at the database for this information, for example.

=cut

sub guess_field_type
{
   Carp::confess "Don't know how to determine field type of [$_[1]]";
}

=head2 lookup_options

This method is called to find possible options for a given field
from the database.  The default method returns undef.

Returns an array reference of key/value pairs for the column passed in.
These values are used for the values and labels for field types that
provide a list of options to select from (e.g. Select, Multiple).

A 'Select' type field (or a field that inherits from
HTML::FormHandler::Field::Select) can set a number of scalars that control how
options are looked up:

    label_column()          - column that holds the label
    active_column()         - column that indicates if a row is acitve
    sort_column()           - column used for sorting the options

The default for label_column is "name".

HTML::FormHandler::Model::CDBI, for example, uses meta_info() to look at related
classes and returns a list of options sorted by the label column which by
default is "name".


=cut

sub lookup_options { return }

=head2 init_value

This method populates a form field's value from the item object.
This is typically done by calling the field's name as an method
on the object.

The default method basically does:

    my $name = $field->name;
    return $item->can( $name ) ? $item->$name : undef
        if blessed( $item );

=cut

sub init_value
{
   my ( $self, $field, $item ) = @_;
   my $name = $field->name;

   return $item->can($name) ? $item->$name : undef
      if blessed($item);

   return $item->{$name};

}

=head2 update_from_form

Update or create the object.

This needs to be overridden in the model subclass or in your
form subclass.

It should update $form->item, if set, otherwise create a new item.

The update/create should be done inside a transaction if do_transaction is
available.

Any field names that are related to the class by "has_many" and have a mapping
table should also be updated.

Validation must also be run unless validation has already been run.
($form->clear might need to be called if the $form object stays in memory
between requests.)

See HTML::FormHandler::Model::CDBI for an example.


The default method dies.

=cut

sub update_from_form
{
   die "must define 'update_from_form' in HTML::FormHandler::Model subclass";
}

=head2 model_validate

Validates profile items that are dependent on the model.
This is called via the validation process and the model class
must at least validate "unique" constraints defined in the form
class.

Any errors on a field found should be set by calling the field's
add_error method:

    $field->add_error('Value must be unique in the database');

The default method does nothing.

=cut

sub model_validate { }

=head1 AUTHOR

Gerda Shank, gshank@cpan.org

Based on the original source code of L<Form::Processor::Field> by Bill Moseley

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose;
1;
