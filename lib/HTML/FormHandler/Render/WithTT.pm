package HTML::FormHandler::Render::WithTT;

use Moose::Role;
use File::ShareDir;
use Template;
use namespace::autoclean; 

requires 'form';

=head1 NAME

HTML::FormHandler::Render::WithTT

=head1 SYNOPSIS

Warning: this feature is not quite ready for prime time. It has not
been well tested and the template widgets aren't complete. Contributions
welcome.

A rendering role for HTML::FormHandler that allows rendering using 
Template::Toolkit

   package MyApp::Form;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';
   with 'HTML::FormHandler::Render::WithTT';

   sub build_tt_template { 'user_form.tt' }
   sub build_tt_include_path { 'root/templates' }
   ....< define form >....

   my $form = MyApp::Form->new( 
   $form->tt_render;


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
);
sub build_tt_include_path {[]}

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
sub build_tt_template { 'form.tt' }

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
sub build_tt_vars {{}}

has 'default_tt_vars' => ( is => 'ro', isa => 'HashRef',
   lazy => 1, builder => 'build_default_tt_vars' );
sub build_default_tt_vars {
    my $self = shift;
    return { form => $self->form };
}

has 'tt_default_options' => ( 
    traits => ['Hash'],
    is => 'rw',
    isa => 'HashRef',
    lazy => 1,
    builder => 'build_tt_default_options',
);
sub build_tt_default_options {{}}


sub tt_render {
    my $self = shift;

    my $output;
    my $vars = { %{$self->default_tt_vars}, %{$self->tt_vars} };
    $self->tt_engine->process( $self->tt_template, $vars, \$output );
    return $output;
}


1;
