package HTML::FormHandler::I18N;
use strict;
use warnings;
use base ('Locale::Maketext');

# general _localize method to use
sub _localize {
    my ( $self, @message ) = @_;

    my $lh;
    # Running without a form object?
    if ( $self->form ) {
        $lh = $self->form->language_handle;
    }
    else {
        $lh = $ENV{LANGUAGE_HANDLE} ||
            HTML::FormHandler::I18N->get_handle ||
            die "Failed call to Locale::Maketext->get_handle";
    }
    return $lh->maketext(@message);

}

1;

