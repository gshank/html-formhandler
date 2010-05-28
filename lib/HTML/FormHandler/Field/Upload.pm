package HTML::FormHandler::Field::Upload;

use Moose;
use Moose::Util::TypeConstraints;

extends 'HTML::FormHandler::Field';

our $VERSION = '0.02';

=head1 NAME

HTML::FormHandler::Field::Upload - File upload field

=head1 DESCRIPTION

This field is designed to be used with a blessed object with a 'size' method,
such as L<Catalyst::Request::Upload>, or a filehandle.
Validates that the file is not empty and is within the 'min_size'
and 'max_size' limits (limits are in bytes).
A form containing this field must have the enctype set.

    package My::Form::Upload;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+enctype' => ( default => 'multipart/form-data');

    has_field 'file' => ( type => 'Upload', max_size => '2000000' );
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
    my $size = 0;
    if( blessed $upload && $upload->can('size') ) {
        $size = $upload->size;
    }
    elsif( is_real_fh( $upload ) ) {
        $size = -s $upload;
    }
    else {
        return $self->add_error('File not found for upload field');
    }
    $size > 0 or
        return $self->add_error('File uploaded is empty');

    $size >= $self->min_size or
        return $self->add_error( 'File is too small (< [_1] bytes)', $self->min_size );

    $size <= $self->max_size or
        return $self->add_error( 'File is too big (> [_1] bytes)', $self->max_size );
}

# stolen from Plack::Util::is_real_fh
sub is_real_fh {
    my $fh = shift;

    my $reftype = Scalar::Util::reftype($fh) or return;
    if( $reftype eq 'IO' 
            or $reftype eq 'GLOB' && *{$fh}{IO} ){
        my $m_fileno = $fh->fileno;
        return unless defined $m_fileno;
        return unless $m_fileno >= 0;
        my $f_fileno = fileno($fh);
        return unless defined $f_fileno;
        return unless $f_fileno >= 0;
        return 1;
    }
    else {
        return;
    }
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

