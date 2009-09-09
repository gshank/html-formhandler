package HTML::FormHandler::Field::Upload;

use Moose;
use Moose::Util::TypeConstraints;

extends 'HTML::FormHandler::Field';

our $VERSION = '0.01';

=head1 NAME

HTML::FormHandler::Field::Upload - File upload field

=head1 DESCRIPTION

Validates that the input is an uploaded file.

=head1 DEPENDENCIES

=head2 widget

Widget type is 'file'

=cut

has '+widget' => ( default => 'upload', );
has minimum   => ( is      => 'rw', isa => 'Int', default => 1 );
has maximum   => ( is      => 'rw', isa => 'Int', default => 1_048_576 );

sub BUILD {
    for my $form ( $_[0]->form ) {
        $form->enctype('multipart/form-data');
        $form->http_method('post');
    }
}

sub minimum_kilobyte {
    my ( $self, $value ) = @_;
    return $self->minimum >> 10 unless $value;
    return $self->minimum( $value << 10 );
}

sub minimum_megabyte {
    my ( $self, $value ) = @_;
    return $self->minimum >> 20 unless $value;
    return $self->minimum( $value << 20 );
}

sub maximum_kilobyte {
    my ( $self, $value ) = @_;
    return $self->maximum >> 10 unless $value;
    return $self->maximum( $value << 10 );
}

sub maximum_megabyte {
    my ( $self, $value ) = @_;
    return $self->maximum >> 20 unless $value;
    return $self->maximum( $value << 20 );
}

sub validate {
    my $self   = shift;
    my $upload = $self->upload();

    blessed $upload and
        $upload->size > 0 or
        return $self->add_error('This is not valid file upload data');

    my $size = $upload->size;

    $size >= $self->minimum or
        return $self->add_error( 'File is too small (< [_1] bytes)', $self->minimum );

    $size <= $self->maximum or
        return $self->add_error( 'File is too big (> [_1] bytes)', $self->maximum );

    return $upload;
}

sub upload {
    my $self = shift;

    return $self->form->ctx->req->upload( $self->name );
}

__PACKAGE__->meta->make_immutable;

=head1 AUTHOR

Bernhard Graf

Oleg Kostyuk, cub.uanic@gmail.com

and FormHandler contributors

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;

