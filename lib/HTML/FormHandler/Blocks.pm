package HTML::FormHandler::Blocks;
# ABSTRACT: used in Wizard

=head1 SYNOPSIS

This is a role which provides the ability to render your form in
arbitrary 'blocks', instead of by fields.

    package MyApp::Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    with 'HTML::FormHandler::Blocks';

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

If you don't include this role, you can declare blocks with 'has_block', but
nothing will be done with them and they won't be used in rendering.

=cut

use Moose::Role;
use Try::Tiny;
use Class::Load qw/ load_optional_class /;
use namespace::autoclean;
use Data::Clone;
use HTML::FormHandler::Widget::Block;

has 'blocks' => (
    isa     => 'HashRef[HTML::FormHandler::Widget::Block]',
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

has 'render_list' => (
    is      => 'rw',
    isa     => 'ArrayRef[Str]',
    traits  => ['Array'],
    builder => 'build_render_list',
    handles => {
        has_render_list    => 'count',
        add_to_render_list => 'push',
    }
);

sub build_render_list { [] }

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
    foreach my $block_attr (@$meta_blist) {
        $self->make_block($block_attr);
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
    if ( $type eq '' ) {
        $class = 'HTML::FormHandler::Widget::Block';
    }
    else {
        foreach my $ns ( @{$self->widget_name_space}, 'HTML::FormHandler::Widget' ) {
            my $try_class = $ns . "::Block::" . $type;
            last if $class = load_optional_class($try_class) ? $try_class : undef;
        }
        die "Could not load block class '$type' for block '$name'"
            unless $class;
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
        $self->add_block( $block->name, $block );
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
    return clone( \@block_list ) if scalar @block_list;
}

sub render {
    my ($self) = @_;

    my $result;
    my $form;
    if ( $self->DOES('HTML::FormHandler::Result') ) {
        $result = $self;
        $form   = $self->form;
    }
    else {
        $result = $self->result;
        $form   = $self;
    }
    my $output = $form->render_start($result);
    $output .= $form->render_form_errors($result);

    if ( $form->has_render_list ) {
        foreach my $fb ( @{ $form->render_list } ) {
            # it's a Field
            if ( $self->field_in_index($fb) ) {
                # find field result and use that
                my $fld_result = $result->get_result($fb);
                # if no result, then we shouldn't be rendering this field
                next unless $fld_result;
                $output .= $fld_result->render;
            }
            # it's a Block
            else {
                # always use form level result for blocks
                my $block = $self->block($fb);
                die "found no field or block named $fb\n" unless $block;
                $output .= $block->render($result);
            }
        }
    }
    else {
        foreach my $fld_result ( $result->results ) {
            $output .= $fld_result->render;
        }
    }

    $output .= $form->render_end($result);
    return $output;
}

1;
