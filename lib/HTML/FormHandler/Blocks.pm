package HTML::FormHandler::Blocks;
# ABSTRACT: arrange form layout using blocks
use strict;
use warnings;

=head1 SYNOPSIS

This is a role which provides the ability to render your form in
arbitrary 'blocks', instead of by fields. This role is included
by default in HTML::FormHandler.

    package MyApp::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';

    sub build_render_list {[ 'foo', 'fset' ]}
    has_field 'foo';
    has_field 'bar';
    has_field 'nox';
    has_block 'fset' => ( tag => 'fieldset', render_list => ['bar', 'nox'] );;
    ....
    $form->render;

Blocks live in the HTML::FormHandler::Widget::Block:: namespace. The default,
non-typed block is L<HTML::FormHandler::Widget::Block>. Provide a type for
custom blocks:

    has_block 'my_block' => ( type => 'CustomBlock', render_list => [...] );

You can also build blocks with a 'block_list' attribute, or the builder for it,
'build_block_list'.

Rendering with blocks is supported by the rendering widgets. Render::Simple doesn't
do it, though it would be possible to make your own custom renderer.

=cut

use Moose::Role;
use Try::Tiny;
use Class::Load qw/ load_optional_class /;
use namespace::autoclean;
use Data::Clone;
use HTML::FormHandler::Widget::Block;

has 'blocks' => (
    isa     => 'HashRef[Object]',
    is      => 'ro',
    lazy    => 1,
    traits  => ['Hash'],
    builder => 'build_blocks',
    handles => {
        has_blocks   => 'count',
        add_block    => 'set',
        block        => 'get',
        block_exists => 'exists',
    },
);
sub build_blocks { {} }

has 'block_list' => ( is => 'rw', isa => 'ArrayRef', lazy => 1, builder => 'build_block_list' );
sub build_block_list {[]}

has 'render_list' => (
    is      => 'rw',
    isa     => 'ArrayRef[Str]',
    traits  => ['Array'],
    lazy    => 1,
    builder => 'build_render_list',
    handles => {
        has_render_list    => 'count',
        add_to_render_list => 'push',
        all_render_list    => 'elements',
        get_render_list    => 'get',
    }
);

sub get_renderer {
    my ( $self, $name ) = @_;
    die "must provide a name to get_renderer" unless $name;
    my $obj = $self->block($name);
    return $obj if ref $obj;
    $obj = $self->field_from_index($name);
    return $obj if ref $obj;
    die "did not find a field or block with name $name\n";
}

after '_build_fields' => sub {
    my $self = shift;

    my $meta_blist = $self->_build_meta_block_list;
    if( @$meta_blist ) {
        foreach my $block_attr (@$meta_blist) {
            $self->make_block($block_attr);
        }
    }
    my $blist = $self->block_list;
    if( @$blist ) {
        foreach my $block_attr (@$blist) {
            $self->make_block($block_attr);
        }
    }
};

sub make_block {
    my ( $self, $block_attr ) = @_;

    my $type = $block_attr->{type} ||= '';
    my $name = $block_attr->{name};
    die "You must supply a name for a block" unless $name;

    my $do_update;
    if ( $name =~ /^\+(.*)/ ) {
        $block_attr->{name} = $name = $1;
        $do_update = 1;
    }

    my $class;
    if( $type ) {
        $class = $self->get_widget_role($type, 'Block');
    }
    else {
        $class = 'HTML::FormHandler::Widget::Block';
    }

    $block_attr->{form} = $self->form if $self->form;

    my $block = $self->form->block( $block_attr->{name} );
    if ( defined $block && $do_update ) {
        delete $block_attr->{name};
        foreach my $key ( keys %{$block_attr} ) {
            $block->$key( $block_attr->{$key} )
                if $block->can($key);
        }
    }
    else    # new block
    {
        $block = $class->new(%$block_attr);
        $self->add_block( $name, $block );
    }
}

# loops through all inherited classes and composed roles
# to find blocks specified with 'has_block'
sub _build_meta_block_list {
    my $self = shift;
    my @block_list;

    foreach my $sc ( reverse $self->meta->linearized_isa ) {
        my $meta = $sc->meta;
        if ( $meta->can('calculate_all_roles') ) {
            foreach my $role ( reverse $meta->calculate_all_roles ) {
                if ( $role->can('block_list') && $role->has_block_list ) {
                    foreach my $block_def ( @{ $role->block_list } ) {
                        push @block_list, $block_def;
                    }
                }
            }
        }
        if ( $meta->can('block_list') && $meta->has_block_list ) {
            foreach my $block_def ( @{ $meta->block_list } ) {
                push @block_list, $block_def;
            }
        }
    }
    return clone( \@block_list );
}


1;
