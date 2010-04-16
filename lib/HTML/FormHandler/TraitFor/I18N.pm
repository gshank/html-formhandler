package HTML::FormHandler::TraitFor::I18N;

use base 'Locale::Maketext';
use HTML::FormHandler::I18N;
use Moose::Role;

=head3 language_handle, _build_language_handle

Holds a Locale::Maketext language handle

The builder for this attribute gets the Locale::Maketext language
handle from the environment variable $ENV{LANGUAGE_HANDLE}, or creates
a default language handler using L<HTML::FormHandler::I18N>. The
language handle is used in the field's add_error method to allow
localizing.

You can pass in an existing L<Locale::MakeText> subclass instance
or create one in a builder.

In a form class:

    sub _build_language_handle { MyApp::I18N::abc_de->new }

Passed into new or process:

    my $lh = MyApp::I18N::abc_de->new;
    my $form = MyApp::Form->new( language_handle => $lh );

If you do not set the language_handle, then L<Locale::Maketext> and/or
L<I18N::LangTags> may guess, with unexpected results.

=cut 

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
    return $ENV{LANGUAGE_HANDLE} || HTML::FormHandler::I18N->get_handle;
}

sub _localize {
    my ($self, @message) = @_;
    $self->language_handle->maketext(@message);
}


1;
