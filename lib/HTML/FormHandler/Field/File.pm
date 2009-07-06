package HTML::FormHandler::Field::File;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::AttributeHelpers;
use Carp 'croak';
use List::MoreUtils 'any';

extends 'HTML::FormHandler::Field';

our $VERSION = '0.01';

=head1 NAME

HTML::FormHandler::Field::File - File upload field

=head1 DESCRIPTION

Validates that the input is an uploaded file.

=head1 DEPENDENCIES

=head2 widget

Widget type is 'file'

=cut

has '+widget' => ( default => 'file' );

subtype 'ArrayRefOfStr' => as 'ArrayRef[Str]';

coerce 'ArrayRefOfStr' => from 'Str' => via { [$_] };

has 'accept' => (
   metaclass => 'Collection::Array',
   is        => 'rw',
   isa       => 'ArrayRefOfStr',
   predicate => 'has_accept',
   coerce    => 1,
   default   => sub { [] },
   provides  => { elements => 'accept_list', }
);

has minimum => ( is => 'rw', isa => 'Int', default => 1 );
has maximum => ( is => 'rw', isa => 'Int', default => 1_048_576 );

sub BUILD
{
   for my $form ( $_[0]->form )
   {
      $form->enctype('multipart/form-data');
      $form->http_method('post');
   }
}

sub minimum_kilobyte
{
   croak "minimum_kilobyte() cannot be used as a getter"
      if @_ < 2;

   return $_[0]->minimum( $_[1] << 10 );
}

sub minimum_megabyte
{
   croak "minimum_megabyte() cannot be used as a getter"
      if @_ < 2;

   return $_[0]->minimum( $_[1] << 20 );
}

sub maximum_kilobyte
{
   croak "maximum_kilobyte() cannot be used as a getter"
      if @_ < 2;

   return $_[0]->maximum( $_[1] << 10 );
}

sub maximum_megabyte
{
   croak "maximum_megabyte() cannot be used as a getter"
      if @_ < 2;

   return $_[0]->maximum( $_[1] << 20 );
}

sub validate
{
   my $self  = $_[0];
   my $value = $self->value;

   return unless $self->SUPER::validate;

   blessed $value          and
      $value->can('fh')    and
      $value->can('slurp') and
      $value->can('type') or
      return $self->add_error('This is not valid file upload data');

   if ( $self->has_accept )
   {
      my $type = $value->type;
      any { $type eq $_ } $self->accept_list or
         return $self->add_error( 'Invalid content-type "[_1]"', $type );
   }

   my $size = $value->can('size') ? $value->size : ( -s $value->fh );

   $size >= $self->minimum or
      return $self->add_error( 'File is too small (< [_1] bytes)', $self->minimum );

   $size <= $self->maximum or
      return $self->add_error( 'File is too big (> [_1] bytes)', $self->maximum );

   return $self->transform;
}

sub transform
{
   my $self = $_[0];

   eval { $self->value( $self->value->slurp ) } or
      return $self->add_error('Cannot read uploaded data');

   return 1;
}

=head1 AUTHOR

Bernhard Graf

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;
1;
