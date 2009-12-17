package HTML::FormHandler::TraitFor::I18N;

use base 'Locale::Maketext';
use Moose::Role;

has 'language_handle' => (
    isa => 'Locale::Maketext',
    is => 'rw',
    lazy_build => 1,
    required => 1,
);

sub _build_language_handle {
    my ($self) = @_;

    if (!$self->isa('HTML::FormHandler') && $self->has_form) {
        return $self->form->language_handle();
    }
    return $ENV{LANGUAGE_HANDLE} // HTML::FormHandler::I18N->get_handle;
}

sub _localize {
    my ($self, @message) = @_;
    $self->language_handle->maketext(@message);
}


1;
