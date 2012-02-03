package MyCatalystApp::Controller::Captcha;

use HTML::FormHandler;

use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

MyCatalystApp::Controller::Captcha - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $form = MyCatalystApp::Controller::Captcha::Form->new(
        ctx => $c,
    );

    if($form->process($c->req->params)){
        $c->res->body("verification succeeded");
    return;
    }
    $c->res->body($form->render);
}

=head2 image

returns the image belonging to the current captcha

=cut

sub image :Local{
    my ( $self, $c ) = @_;
    my $captcha = $c->session->{captcha};
    $c->res->content_type($captcha->{type});
    my $filename = "captcha." . $captcha->{type};
    $c->res->header('Content-Disposition', qq[attachment; filename=$filename]);
    $c->res->body($captcha->{image});
}

sub get_rnd :Local{
    my ( $self, $c ) = @_;
    my $captcha = $c->session->{captcha};
    die "no captcha in session" unless $captcha;
    $c->res->body($captcha->{rnd});
}

=head1 AUTHOR

Lukas Thiemeier,1R/18,7289,none

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

{
    package MyCatalystApp::Controller::Captcha::Form;

    use HTML::FormHandler::Moose;
    extends qw/HTML::FormHandler/;
    with qw/
        HTML::FormHandler::Render::Simple
        HTML::FormHandler::TraitFor::Captcha
    /;

    has_field submit => ( type => "Submit" );

    __PACKAGE__->meta->make_immutable;
    1;
}

1;
