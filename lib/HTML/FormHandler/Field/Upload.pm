package HTML::FormHandler::Field::Upload;

use Moose;
use Moose::Util::TypeConstraints;

extends 'HTML::FormHandler::Field';

our $VERSION = '0.02';

=head1 NAME

HTML::FormHandler::Field::Upload - File upload field

=head1 DESCRIPTION

This field is designed to be used with L<Catalyst::Request::Upload>.
Validates that the input is an uploaded file.
A form containing this field must have the enctype set.

    package My::Form::Upload;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+enctype' => ( default => 'multipart/form-data');

    has_field 'file' => ( type => 'Upload' );
    has_field 'submit' => ( type => 'Submit', value => 'Upload' );

In your controller:

    my $form = My::Form::Upload->new; 
    my @params = ( file => $c->req->upload('file') ) 
             if $c->req->method eq 'POST';
    $form->process( params => { @params } );
    return unless ( $form->validated );

=head1 DEPENDENCIES

=head2 widget

Widget type is 'upload'

=cut

has '+widget' => ( default => 'upload', );
has min_size   => ( is      => 'rw', isa => 'Int', default => 1 );
has max_size   => ( is      => 'rw', isa => 'Int', default => 1048576 );


sub validate {
    my $self   = shift;

    my $upload = $self->value;
    blessed($upload) and
        $upload->size > 0 or
        return $self->add_error('File uploaded is empty');

    my $size = $upload->size;

    $upload->size >= $self->min_size or
        return $self->add_error( 'File is too small (< [_1] bytes)', $self->min_size );

    $upload->size <= $self->max_size or
        return $self->add_error( 'File is too big (> [_1] bytes)', $self->max_size );
}

__PACKAGE__->meta->make_immutable;

=head1 AUTHOR

Bernhard Graf & Oleg Kostyuk

and FormHandler contributors

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;

