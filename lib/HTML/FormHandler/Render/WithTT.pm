package HTML::FormHandler::Render::WithTT;
# ABSTRACT: tt rendering

use Moose::Role;
use File::ShareDir;
use Template;
use namespace::autoclean;
use HTML::FormHandler::Render::Util ('process_attrs');

=head1 SYNOPSIS

A rendering role for HTML::FormHandler that allows rendering using
Template::Toolkit

   package MyApp::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';
   with 'HTML::FormHandler::Render::WithTT';

   sub build_tt_template { 'user_form.tt' }
   sub build_tt_include_path { ['root/templates'] }
   ....< define form >....

   my $form = MyApp::Form->new(
   $form->tt_render;

If you want to render with TT, you don't need this role. Just use
one of the TT form templates provided, form.tt or form_in_one.tt.
If you use this role to render, you are using two different TT
engines, with different sets of variables, etc, which doesn't
make much sense.

This is mainly useful as a testing aid and an example of using the
sample templates.

=head1 DESCRIPTION

Uses 'tt_render' instead of 'render' to allow using both TT templates and the
built-in rendering.

=cut

has 'tt_include_path' => (
    traits => ['Array'],
    is => 'rw',
    isa => 'ArrayRef',
    lazy => 1,
    builder => 'build_tt_include_path',
    handles => {
       add_tt_include_path => 'push',
    }
);
sub build_tt_include_path { return []; }

has 'tt_config' => (
    traits => ['Hash'],
    is => 'rw',
    lazy => 1,
    builder => 'build_tt_config',
);
sub build_tt_config {
    my $self = shift;
    return {
        INCLUDE_PATH => [
           @{ $self->tt_include_path },
           File::ShareDir::dist_dir('HTML-FormHandler') . '/templates/'
        ]
    };
}

# either file name string or string ref?
has 'tt_template' => ( is => 'rw', isa => 'Str', lazy => 1,
   builder => 'build_tt_template' );
sub build_tt_template { return 'form/form.tt'; }

has 'tt_engine' => ( is => 'rw', isa => 'Template', lazy => 1,
   builder => 'build_tt_engine'
);
sub build_tt_engine {
    my $self = shift;

    my $tt_engine = Template->new( $self->tt_config );
    return $tt_engine;
}

has 'tt_vars' => ( is => 'rw', traits => ['Hash'],
    builder => 'build_tt_vars');
sub build_tt_vars { return {}; }

has 'default_tt_vars' => ( is => 'ro', isa => 'HashRef',
   lazy => 1, builder => 'build_default_tt_vars' );
sub build_default_tt_vars {
    my $self = shift;
    return { form => $self->form, process_attrs => \&process_attrs };
}

has 'tt_default_options' => (
    traits => ['Hash'],
    is => 'rw',
    isa => 'HashRef',
    lazy => 1,
    builder => 'build_tt_default_options',
);
sub build_tt_default_options { return {}; }


sub tt_render {
    my $self = shift;

    my $output;
    my $vars = { %{$self->default_tt_vars}, %{$self->tt_vars} };
    $self->tt_engine->process( $self->tt_template, $vars, \$output );

    if( my $exception = $self->tt_engine->{SERVICE}->{_ERROR} ) {

        die $exception->[0] . " " . $exception->[1] . ".  So far => " . ${$exception->[2]} . "\n";
    }
    return $output;
}

1;
