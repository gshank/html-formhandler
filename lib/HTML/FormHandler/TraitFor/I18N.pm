package HTML::FormHandler::TraitFor::I18N;

use HTML::FormHandler::I18N;
use Moose::Role;
use Moose::Util::TypeConstraints;

=head3 language_handle, _build_language_handle

Holds a Locale::Maketext (or other duck_type class with a 'maketext'
method) language handle

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

You can use non-Locale::Maketext language handles, such as L<Data::Localize>.
There's an example of building a L<Data::Localize> language handle
in t/xt/locale_data_localize.t in the distribution.

=cut 

has 'language_handle' => (
    isa => duck_type( [ qw(maketext) ] ),
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
    my $message = $self->language_handle->maketext(@message);
    return $message;
}

no Moose::Role;
no Moose::Util::TypeConstraints;

1;
