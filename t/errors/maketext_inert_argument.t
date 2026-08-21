use strict;
use warnings;
use Test::More;
use Test::Exception;

# Text this distribution did not author must not be used as the Locale::Maketext
# FORMAT. Maketext compiles a '[...]' group in the format into a method call, so
# any such text carrying request data lets a submitted value reach a method on
# the language handle, with the submitter choosing the method and its arguments.
#
# The first five blocks below FAIL without the fix: the payload is dispatched
# instead of shown, or form processing dies outright. The remaining tests assert
# the behaviour the fix must not break -- ordinary messages, bracket notation in
# templates this distribution or the application authored, and lexicon lookup of
# a message that merely happens to be translatable. Those pass either way, by
# design; they are the regression guard.

{
    package Test::Inert::Warn;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    # An ordinary numeric transform. It succeeds, but it warns, and Perl quotes
    # the offending value into the warning verbatim -- so the submitted value
    # lands in text that _apply_actions traps and turns into a message. The
    # coderef must be compiled under 'use warnings' (as it is here) for the
    # warning to happen at all.
    has_field 'qty' => (
        type  => 'Text',
        apply => [ { transform => sub { $_[0] + 0 } } ],
    );
    no HTML::FormHandler::Moose;
}

{
    package Test::Inert::ValueAsMessage;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    has_field 'echo' => ( type => 'Text' );
    # add_error($value) where a duplicate request parameter made $value an
    # arrayref: the arrayref lands where a template and its arguments go.
    sub validate_echo { my ( $self, $field ) = @_; $field->add_error( $field->value ) }
    no HTML::FormHandler::Moose;
}

{
    package Test::Inert::Typed;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    has_field 'nickname' => ( type => 'Text', apply => [ { type => 'Str' } ] );
    no HTML::FormHandler::Moose;
}

{
    package Test::Inert::MaxLen;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    has_field 'short' => ( type => 'Text', maxlength => 3 );
    no HTML::FormHandler::Moose;
}

{
    package Test::Inert::Template;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    has_field 'tags' => ( type => 'Text' );
    # The documented spelling: the template is the application's, the value is
    # an argument. Bracket notation in it must still compile.
    sub validate_tags {
        my ( $self, $field ) = @_;
        $field->add_error( 'Too many [quant,_1,tag,tags] in [_2]', 3, $field->value );
    }
    no HTML::FormHandler::Moose;
}

# A custom type whose message is a phrase the application has in its lexicon.
# Text this distribution did not author is never used as the format, so it is
# never a lexicon key either: the message is shown as the type gave it. That is
# a deliberate consequence and is asserted here so it cannot change silently.
{
    package Test::Inert::L10N;
    our @ISA = ('HTML::FormHandler::I18N');
    package Test::Inert::L10N::en;
    our @ISA = ('Test::Inert::L10N');
    our %Lexicon = ( '_AUTO' => 1, 'Must be positive' => 'TRANSLATED OK' );
}
{
    package Test::Inert::Translated;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    use Moose::Util::TypeConstraints;
    subtype 'TestInertPositive',
        as      'Int',
        where   { $_ > 0 },
        message { 'Must be positive' };
    has_field 'p' => ( type => 'Text', apply => [ { type => 'TestInertPositive' } ] );
    no HTML::FormHandler::Moose;
}

# An exception object, or any other reference, reaching one of those sources.
# Locale::Maketext stringifies its format argument -- honouring a '""' overload
# -- so text arriving inside an object must be diverted just as a plain string
# is, or the object becomes a way around the whole thing.
{
    package Test::Inert::Strung;
    use overload '""' => sub { $_[0]->{text} }, fallback => 1;
    sub new { my ( $class, %a ) = @_; return bless {%a}, $class }
}

{
    package Test::Inert::Dies;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    has 'boom' => ( is => 'rw' );
    has_field 'f' => (
        type  => 'Text',
        apply => [ { transform => sub { die $_[1]->form->boom } } ],
    );
    no HTML::FormHandler::Moose;
}

sub errors_of {
    my $form = shift;
    return join ' | ', map { $_->all_errors } $form->fields;
}

# --------------------------------------------------------------------------
# These five blocks fail without the fix.
# --------------------------------------------------------------------------

# A method call in a trapped warning must be shown, not dispatched. sprintf is
# used with a small width on purpose: the point is to detect that dispatch
# happened at all, not to allocate anything.
{
    my $form = Test::Inert::Warn->new;
    lives_ok { $form->process( params => { qty => '[sprintf,%20d,7]' } ) }
        'a bracket group in a trapped warning does not kill form processing';
    my $errors = errors_of($form);
    like $errors, qr/\Q[sprintf,%20d,7]\E/,
        'the bracket group is shown literally in the error message';
    unlike $errors, qr/\s{15,}7/,
        'sprintf was not called (no padded output in the message)';
}

# A bracket group that does not compile must not become an exception. Without
# the fix this reaches Locale::Maketext's code generator and dies, which
# add_error re-raises: an unhandled error out of process().
{
    my $form = Test::Inert::Warn->new;
    lives_ok { $form->process( params => { qty => '[0]' } ) }
        'a malformed bracket group in a trapped warning does not die';
    like errors_of($form), qr/\Q[0]\E/, 'it is shown literally too';
}

# A duplicate request parameter must not supply a template and its arguments.
{
    my $form = Test::Inert::ValueAsMessage->new;
    lives_ok { $form->process( params => { echo => [ '[quant,_1,x]', '9' ] } ) }
        'an arrayref value passed to add_error does not die';
    my $errors = errors_of($form);
    like $errors, qr/\Q[quant,_1,x]\E/, 'element 0 is shown literally';
    unlike $errors, qr/\b9 xs\b/,
        'quant was not called with the submitter\'s argument';
}

# A type constraint renders a rejected reference in bracket-and-comma form into
# its own failure message, so a duplicate parameter alone is enough. Moose only
# renders it that way when it can load a dumper, so skip when it cannot.
SKIP: {
    skip 'Devel::PartialDump not available, so the type-constraint message does '
        . 'not render the rejected value as a bracket group', 1
        unless eval { require Devel::PartialDump; Devel::PartialDump->VERSION(0.14); 1 };
    my $form = Test::Inert::Typed->new;
    lives_ok { $form->process( params => { nickname => [ 'a', 'b' ] } ) }
        'a duplicate parameter on a typed field does not die';
}


# A payload carried inside an exception object must be shown, not dispatched.
{
    my $form = Test::Inert::Dies->new(
        boom => Test::Inert::Strung->new( text => '[sprintf,%20d,7]' ) );
    lives_ok { $form->process( params => { f => 'x' } ) }
        'an exception object stringifying to a bracket group does not kill '
      . 'form processing';
    my $errors = errors_of($form);
    like $errors, qr/\Q[sprintf,%20d,7]\E/,
        'the object\'s stringification is shown literally';
    unlike $errors, qr/\s{15,}7/,
        'sprintf was not called through the object';
}

# --------------------------------------------------------------------------
# These pass with and without the fix. They are the regression guard.
# --------------------------------------------------------------------------

{
    my $form = Test::Inert::MaxLen->new;
    $form->process( params => { short => 'abcdef' } );
    like errors_of($form), qr/should not exceed/,
        'an ordinary built-in message is unchanged';
}

{
    my $form = Test::Inert::Template->new;
    $form->process( params => { tags => 'a,b,c' } );
    my $errors = errors_of($form);
    like $errors, qr/Too many 3 tags/,
        'bracket notation in an application template still compiles';
    like $errors, qr/\Qa,b,c\E/, 'and its argument is interpolated';
}

{
    my $form = Test::Inert::Warn->new;
    $form->process( params => { qty => 'abc' } );
    like errors_of($form), qr/isn't numeric/,
        'a warning with no bracket metacharacters is still used as the message';
}

{
    my $lh = Test::Inert::L10N->get_handle('en');
    my $form = Test::Inert::Translated->new( language_handle => $lh );
    $form->process( params => { p => '-5' } );
    is errors_of($form), 'Must be positive',
        'a type constraint message is shown as the type gave it -- foreign text '
        . 'is never used as the format, so it is never a lexicon key either';
}

done_testing;
