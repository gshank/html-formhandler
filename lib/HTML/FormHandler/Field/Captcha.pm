package HTML::FormHandler::Field::Captcha;
# ABSTRACT: captcha field with GD::SecurityImage

use Moose;
extends 'HTML::FormHandler::Field';
use HTTP::Date;

=head1 SYNOPSIS

A Captcha class using GD::SecurityImage.
Requires that three methods be available from a form object:

  $self->form->get_captcha;
  $self->form->set_captcha;

Using Catalyst and the Catalyst session plugin this field can be used
in a form by using L<HTML::FormHandler::TraitFor::Captcha>.

   package MyApp::Form::Post;
   use HTML::FormHandler::Moose;
   with 'HTML::FormHandler::TraitFor::Captcha';

You can set the following attributes on the 'captcha' field:

   height, width, scramble, lines, gd_font

Example:

   has 'captcha' => ( height => '24', width => '70' );

=cut

has 'height'   => ( isa => 'Int', is => 'rw', default => '20' );
has 'width'    => ( isa => 'Int', is => 'rw', default => '80' );
has 'scramble' => ( isa => 'Int', is => 'rw', default => '0' );
has 'lines'    => ( isa => 'Int', is => 'rw', default => '2' );
has 'gd_font'  => ( isa => 'Str', is => 'rw', default => 'Large' );
has 'image'    => ( is  => 'rw' );
has '+css_class' => ( default => 'captcha' );
has '+widget' => ( default => 'Captcha' );

has '+noupdate' => ( default => 1 );

our $class_messages = {
    'captcha_verify_failed' => 'Verification incorrect. Try again.',
};

sub get_class_messages  {
    my $self = shift;
    return {
        %{ $self->next::method },
        %$class_messages,
    }
}

sub get_default_value {
    my $self = shift;

    my $captcha = $self->form->get_captcha;
    # setting the widget after the field is instantiated
    # doesn't actually work. The Captcha widget checks for
    # this setting though.
    if ($captcha) {
        if ( $captcha->{validated} ) {
            $self->required(0);
            $self->widget('NoRender');
        }
        else {
            $self->required(1);
            $self->widget('Captcha');
            $self->image( $captcha->{image} );
        }
    }
    else {
        $self->required(1);
        $self->widget('Captcha');
        $self->gen_captcha;
    }
    return;
}

sub validate {
    my $self = shift;

    my $captcha = $self->form->get_captcha;
    unless ( $captcha->{rnd} eq $self->value ) {
        $self->add_error($self->get_message('captcha_verify_failed'));
        $self->gen_captcha;
    }
    else {
        $captcha->{validated} = 1;
    }
    return !$self->has_errors;
}

sub fif { }

sub gen_captcha {
    my $self = shift;

    require GD::SecurityImage;
    my ( $image, $type, $rnd ) = GD::SecurityImage->new(
        height   => $self->height,
        width    => $self->width,
        scramble => $self->scramble,
        lines    => $self->lines,
        gd_font  => $self->gd_font,
    )->random->create->out;
    my $captcha = {
        image     => $image,
        type      => $type,
        rnd       => $rnd,
        validated => 0,
    };
    $self->image($image);
    $self->form->set_captcha($captcha);
}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
