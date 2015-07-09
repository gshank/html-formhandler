package HTML::FormHandler::BuildPages;
# ABSTRACT: used in Wizard
use strict;
use warnings;

use Moose::Role;
use Try::Tiny;
use Class::Load qw/ load_optional_class /;
use namespace::autoclean;

has 'page_list' => (
    isa => 'ArrayRef',
    is => 'rw',
    traits => ['Array'],
    default => sub { [] },
);

sub has_page_list {
    my ( $self ) = @_;

    my $page_list = $self->page_list;
    return unless $page_list && ref $page_list eq 'ARRAY';
    return $page_list if ( scalar @{$page_list} );
    return;
}

after '_build_fields' => sub {
    my $self = shift;

    my $meta_plist = $self->_build_meta_page_list;
    $self->_process_page_array( $meta_plist, 0 ) if $meta_plist;
    my $plist = $self->has_page_list;
    $self->_process_page_list($plist) if $plist;

    return unless $self->has_pages;
};

sub _process_page_list {
    my ( $self, $plist ) = @_;

    if ( ref $plist eq 'ARRAY' ) {
        my @plist_copy = @{$plist};
        $self->_process_page_array( $self->_array_pages( \@plist_copy ) );
        return;
    }
    my %plist_copy = %{$plist};
    $plist = \%plist_copy;
}

sub _array_pages {
    my ( $self, $pages ) = @_;

    my @new_pages;
    while (@$pages) {
        my $name = shift @$pages;
        my $attr = shift @$pages;
        unless ( ref $attr eq 'HASH' ) {
            $attr = { type => $attr };
        }
        push @new_pages, { name => $name, %$attr };
    }
    return \@new_pages;
}

sub _process_page_array {
    my ( $self, $pages ) = @_;

    my $num_pages   = scalar @$pages;
    my $num_dots     = 0;
    my $count_pages = 0;
    while ( $count_pages < $num_pages ) {
        foreach my $page (@$pages) {
            my $count = ( $page->{name} =~ tr/\.// );
            next unless $count == $num_dots;
            $self->_make_page($page);
            $count_pages++;
        }
        $num_dots++;
    }
}

sub _make_page {
    my ( $self, $page_attr ) = @_;

    $page_attr->{type} ||= 'Simple';
    my $type = $page_attr->{type};
    my $name = $page_attr->{name};
    return unless $name;

    my $do_update;
    if ( $name =~ /^\+(.*)/ ) {
        $page_attr->{name} = $name = $1;
        $do_update = 1;
    }
    my @page_name_space;
    my $page_ns = $self->page_name_space;
    if( $page_ns ) {
        @page_name_space = ref $page_ns eq 'ARRAY' ? @$page_ns : $page_ns;
    }
    my @classes;
    # '+'-prefixed fields could be full namespaces
    if ( $type =~ s/^\+// )
    {
        push @classes, $type;
    }
    foreach my $ns ( @page_name_space, 'HTML::FormHandler::Page', 'HTML::FormHandlerX::Page' )
    {
        push @classes, $ns . "::" . $type;
    }
    # look for Page in possible namespaces
    my $class;
    foreach my $try ( @classes ) {
        last if $class = load_optional_class($try) ? $try : undef;
    }
    die "Could not load page class '$type' for field '$name'"
       unless $class;

    $page_attr->{form} = $self->form if $self->form;
    # parent and name correction for names with dots
    if ( $page_attr->{name} =~ /\./ ) {
        my @names       = split /\./, $page_attr->{name};
        my $simple_name = pop @names;
        my $parent_name = join '.', @names;
        my $parent      = $self->page($parent_name);
        if ($parent) {
            $page_attr->{parent} = $parent;
            $page_attr->{name}   = $simple_name;
        }
    }
    elsif ( !( $self->form && $self == $self->form ) ) {
        # set parent
        $page_attr->{parent} = $self;
    }
    $self->_update_or_create_page( $page_attr->{parent} || $self->form,
        $page_attr, $class, $do_update );
}

sub _update_or_create_page {
    my ( $self, $parent, $page_attr, $class, $do_update ) = @_;

    my $index = $parent->page_index( $page_attr->{name} );
    my $page;
    if ( defined $index ) {
        if ($do_update)    # this page started with '+'. Update.
        {
            $page = $parent->page( $page_attr->{name} );
            die "Page to update for " . $page_attr->{name} . " not found"
                unless $page;
            delete $page_attr->{name};
            foreach my $key ( keys %{$page_attr} ) {
                $page->$key( $page_attr->{$key} )
                    if $page->can($key);
            }
        }
        else               # replace existing page
        {
            $page = $self->new_page_with_traits( $class, $page_attr);
            $parent->set_page_at( $index, $page );
        }
    }
    else                   # new page
    {
        $page = $self->new_page_with_traits( $class, $page_attr);
        $parent->push_page($page);
    }
}

sub new_page_with_traits {
    my ( $self, $class, $page_attr ) = @_;

    my $widget = $page_attr->{widget};
    my $page;
    unless( $widget ) {
        my $attr = $class->meta->find_attribute_by_name( 'widget' );
        if ( $attr ) {
            $widget = $attr->default;
        }
    }
    my @traits;
    if( $page_attr->{traits} ) {
        @traits = @{$page_attr->{traits}};
        delete $page_attr->{traits};
    }
    if( $widget ) {
        my $widget_role = $self->get_widget_role( $widget, 'Page' );
        push @traits, $widget_role;
    }
    if( @traits ) {
        $page = $class->new_with_traits( traits => \@traits, %{$page_attr} );
    }
    else {
        $page = $class->new( %{$page_attr} );
    }
    return $page;
}

# loops through all inherited classes and composed roles
# to find pages specified with 'has_page'
sub _build_meta_page_list {
    my $self = shift;
    my @page_list;

    foreach my $sc ( reverse $self->meta->linearized_isa ) {
        my $meta = $sc->meta;
        if ( $meta->can('calculate_all_roles') ) {
            foreach my $role ( reverse $meta->calculate_all_roles ) {
                if ( $role->can('page_list') && $role->has_page_list ) {
                    foreach my $page_def ( @{ $role->page_list } ) {
                        my %new_page = %{$page_def};    # copy hashref
                        push @page_list, \%new_page;
                    }
                }
            }
        }
        if ( $meta->can('page_list') && $meta->has_page_list ) {
            foreach my $page_def ( @{ $meta->page_list } ) {
                my %new_page = %{$page_def};            # copy hashref
                push @page_list, \%new_page;
            }
        }
    }
    return \@page_list if scalar @page_list;
}

1;
