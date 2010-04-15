use strict;
use warnings;
use Test::More;

use_ok('HTML::FormHandler::Field::Upload');

{
    package Mock::Upload;
    use Moose;
    use File::Copy ();
    use IO::File   ();
    use File::Spec::Unix;

    has filename => ( is => 'rw' );
    has size     => ( is => 'rw' );
    has tempname => ( is => 'rw' );
    has basename => ( is => 'ro', lazy_build => 1 );
    has fh => (
        is       => 'rw',
        required => 1,
        lazy     => 1,
        default  => sub {
            my $self = shift;
            my $fh = IO::File->new( $self->tempname, IO::File::O_RDONLY );
            unless ( defined $fh ) {
                my $filename = $self->tempname;
                die "Can't open '$filename': '$!'";
            }
            return $fh;
        },
    );

    sub _build_basename {
        my $self     = shift;
        my $basename = $self->filename;
        $basename =~ s|\\|/|g;
        $basename = ( File::Spec::Unix->splitpath($basename) )[2];
        $basename =~ s|[^\w\.-]+|_|g;
        return $basename;
    }

    sub copy_to {
        my $self = shift;
        return File::Copy::copy( $self->tempname, @_ );
    }

    sub link_to {
        my ( $self, $target ) = @_;
        return CORE::link( $self->tempname, $target );
    }

    sub slurp {
        my ( $self, $layer ) = @_;
        unless ($layer) {
            $layer = ':raw';
        }
        my $content = undef;
        my $handle  = $self->fh;
        binmode( $handle, $layer );
        while ( $handle->sysread( my $buffer, 8192 ) ) {
            $content .= $buffer;
        }
        return $content;
    }
}
{

    package My::Form::Upload;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    has '+enctype' => ( default => 'multipart/form-data');

    has_field 'file' => ( type => 'Upload' );
    has_field 'submit' => ( type => 'Submit', value => 'Upload' );
}

my $form = My::Form::Upload->new;
ok( $form, 'created form with upload field' );

is( $form->field('file')->render, '
<div><label class="label" for="file">File: </label><input type="file" name="file" id="file" /></div>
', 'renders ok' );

my $upload = Mock::Upload->new( filename => 'test.txt', size => 1024 );

$form->process( params => { file => $upload } ); 
ok( $form->validated, 'form validated' );

$upload->size( 20000000 );
$form->process( params => { file => $upload } );
ok( !$form->validated, 'form did not validate' );



done_testing;
