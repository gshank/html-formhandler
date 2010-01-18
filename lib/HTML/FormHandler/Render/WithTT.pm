package HTML::FormHandler::Render::WithTT;

use Moose::Role;
use File::ShareDir;
use Template;
use namespace::autoclean; 

requires 'form';

has 'tt_include_path' => (
    traits => ['Array'],
    is => 'rw',
    isa => 'ArrayRef[Str',
    lazy => 1,
    default => sub { return [] },
);

has 'tt_config' => (
    traits => ['HashRef'],
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
has 'tt_template' => ( is => 'rw', isa => 'Str', lazy => 1, default => 'form.tt' );

has 'tt_engine' => ( is => 'rw', isa => 'Template', lazy => 1,
   builder => 'build_tt_engine'
);

has 'tt_vars' => ( is => 'rw', traits => ['HashRef'], 
   is => 'rw', lazy => 1, default => {{}} );
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
    default => sub { {} },
);
sub build_tt_engine {
    my $self = shift;

    my $tt_engine = Template->new( $self->tt_config );
    return $tt_engine;
}


sub render {
    my $self = shift;

    my $output;
    my $vars = { %{$self->default_tt_vars}, $self->tt_vars };
    $self->tt_engine->process( $self->tt_template, $vars, \$output );
    return $output;
}


1;
