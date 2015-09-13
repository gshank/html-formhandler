package HTML::FormHandler::TraitFor::I18N;
# ABSTRACT: localization
use strict;
use warnings;

use HTML::FormHandler::I18N;
use Moose::Role;
use Moose::Util::TypeConstraints;

=head3 language_handle, _build_language_handle

Holds a Locale::Maketext (or other duck_type class with a 'maketext'
method) language handle. The language handle is used to localize the
error messages in the field's 'add_error' method. It's also used
in various places in rendering to localize labels and button values,
etc.

The builder for this attribute gets the Locale::Maketext language
handle from the environment variable $ENV{LANGUAGE_HANDLE}:

    $ENV{LANGUAGE_HANDLE} = 'en_en';

...or creates a default language handler using L<HTML::FormHandler::I18N>.
(Note that earlier versions required an actual object reference in ENV,
which is a bad practice and no longer supported.)
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

If you don't want a particular error message to go through localization,
you can use 'push_errors' and 'push_form_errors' instead of 'add_error' and
'add_form_errors'.

Example of getting the language handle from the Catalyst context (where the Catalyst
context is passed in with 'ctx'):

    has '+language_handle' => ( builder => 'get_language_handle_from_ctx' );
    sub get_language_handle_from_ctx {
        my $self = shift;
        return MyApp::I18N->get_handle(
            @{ $self->ctx->languages } );
    }


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
    my $lh;
    if ( $ENV{LANGUAGE_HANDLE} ) {
        if ( blessed $ENV{LANGUAGE_HANDLE} ) {
            $lh = $ENV{LANGUAGE_HANDLE};
        }
        else {
            $lh = HTML::FormHandler::I18N->get_handle( $ENV{LANGUAGE_HANDLE} );
        }
    }
    else {
       $lh =  HTML::FormHandler::I18N->get_handle;
    }
    return $lh;
}

sub _localize {
    my ($self, @message) = @_;
    my $message = $self->language_handle->maketext(@message);
    return $message;
}

no Moose::Role;
no Moose::Util::TypeConstraints;

1;
