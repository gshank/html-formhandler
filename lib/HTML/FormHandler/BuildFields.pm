package HTML::FormHandler::BuildFields;
# ABSTRACT: role to build field array

use Moose::Role;
use Try::Tiny;
use Class::Load qw/ load_optional_class /;
use namespace::autoclean;
use HTML::FormHandler::Merge ('merge');
use Data::Clone;

=head1 SYNOPSIS

These are the methods that are necessary to build the fields arrays
in a form. This is a role which is composed into L<HTML::FormHandler>.

Internal code only. This role has no user interfaces.

=cut

has 'fields_from_model' => ( isa => 'Bool', is => 'rw' );

has 'field_list' => ( isa => 'HashRef|ArrayRef', is => 'rw', default => sub { {} } );

has 'build_include_method' => ( is => 'ro', isa => 'CodeRef', traits => ['Code'],
    default => sub { \&default_build_include  }, handles => { build_include => 'execute_method' } );
has 'include' => ( is => 'rw', isa => 'ArrayRef', traits => ['Array'], builder => 'build_include',
    lazy => 1, handles => { has_include => 'count' } );
sub default_build_include { [] }

sub has_field_list {
    my ( $self, $field_list ) = @_;
    $field_list ||= $self->field_list;
    if ( ref $field_list eq 'HASH' ) {
        return $field_list if ( scalar keys %{$field_list} );
    }
    elsif ( ref $field_list eq 'ARRAY' ) {
        return $field_list if ( scalar @{$field_list} );
    }
    return;
}


# This is the only entry point for this file.  It processes the
# various methods of field definition (has_field plus the attrs above),
# creates objects for fields and writes them into the 'fields' attr
# on the base object.
#
# calls routines to process various field lists
# orders the fields after processing in order to skip
# fields which have had the 'order' attribute set
sub _build_fields {
    my $self = shift;

    my $meta_flist = $self->_build_meta_field_list;

    $self->_process_field_array( $meta_flist, 0 ) if $meta_flist;
    my $flist = $self->has_field_list;
    if( $flist ) {
        if( ref($flist) eq 'ARRAY' && ref( $flist->[0] ) eq 'HASH' ) {
            $self->_process_field_array( $flist );
        }
        else {
            $self->_process_field_list( $flist );
        }
    }
    my $mlist = $self->model_fields if $self->fields_from_model;
    $self->_process_field_list( $mlist ) if $mlist;

    return unless $self->has_fields;

    $self->_order_fields;

}


# loops through all inherited classes and composed roles
# to find fields specified with 'has_field'
sub _build_meta_field_list {
    my $self = shift;
    my $field_list = [];

    foreach my $sc ( reverse $self->meta->linearized_isa ) {
        my $meta = $sc->meta;
        if ( $meta->can('calculate_all_roles') ) {
            foreach my $role ( reverse $meta->calculate_all_roles ) {
                if ( $role->can('field_list') && $role->has_field_list ) {
                    foreach my $fld_def ( @{ $role->field_list } ) {
                        push @$field_list, $fld_def;
                    }
                }
            }
        }
        if ( $meta->can('field_list') && $meta->has_field_list ) {
            foreach my $fld_def ( @{ $meta->field_list } ) {
                push @$field_list, $fld_def;
            }
        }
    }
    return $field_list if scalar @$field_list;
}

sub _process_field_list {
    my ( $self, $flist ) = @_;

    if ( ref $flist eq 'ARRAY' ) {
        $self->_process_field_array( $self->_array_fields( $flist ) );
    }
}

# munges the field_list array into an array of field attributes
sub _array_fields {
    my ( $self, $fields ) = @_;

    $fields = clone( $fields );
    my @new_fields;
    while (@$fields) {
        my $name = shift @$fields;
        my $attr = shift @$fields;
        unless ( ref $attr eq 'HASH' ) {
            $attr = { type => $attr };
        }
        push @new_fields, { name => $name, %$attr };
    }
    return \@new_fields;
}

# loop through array of field hashrefs
sub _process_field_array {
    my ( $self, $fields ) = @_;

    # clone and, optionally, filter fields
    $fields = $self->clean_fields( $fields );
    # the point here is to process fields in the order parents
    # before children, so we process all fields with no dots
    # first, then one dot, then two dots...
    my $num_fields   = scalar @$fields;
    my $num_dots     = 0;
    my $count_fields = 0;
    while ( $count_fields < $num_fields ) {
        foreach my $field (@$fields) {
            my $count = ( $field->{name} =~ tr/\.// );
            next unless $count == $num_dots;
            $self->_make_field($field);
            $count_fields++;
        }
        $num_dots++;
    }
}

sub clean_fields {
    my ( $self, $fields ) = @_;
    if( $self->has_include ) {
        my @fields;
        my %include = map { $_ => 1 } @{ $self->include };
        foreach my $fld ( @$fields ) {
            push @fields, clone($fld) if exists $include{$fld->{name}};
        }
        return \@fields;
    }
    return clone( $fields );
}

# Maps the field type to a field class, finds the parent,
# sets the 'form' attribute, calls update_or_create
# The 'field_attr' hashref must have a 'name' key
sub _make_field {
    my ( $self, $field_attr ) = @_;

    my $type = $field_attr->{type} ||= 'Text';
    my $name = $field_attr->{name};

    my $do_update;
    if ( $name =~ /^\+(.*)/ ) {
        $field_attr->{name} = $name = $1;
        $do_update = 1;
    }

    my $class = $self->_find_field_class( $type, $name );

    my $parent = $self->_find_parent( $field_attr );

    $field_attr = $self->_merge_updates( $field_attr, $class ) unless $do_update;

    my $field = $self->_update_or_create( $parent, $field_attr, $class, $do_update );

    $self->form->add_to_index( $field->full_name => $field ) if $self->form;
}

sub _make_adhoc_field {
    my ( $self, $class, $field_attr ) = @_;

    # remove and save form & parent, because if the form class has a 'clone'
    # method, Data::Clone::clone will clone the form
    my $parent = delete $field_attr->{parent};
    my $form = delete $field_attr->{form};
    $field_attr = $self->_merge_updates( $field_attr, $class );
    $field_attr->{parent} = $parent;
    $field_attr->{form} = $form;
    my $field = $self->new_field_with_traits( $class, $field_attr );
    return $field;
}

sub _find_field_class {
    my ( $self, $type, $name ) = @_;

    my $field_ns = $self->field_name_space;
    my @classes;
    # '+'-prefixed fields could be full namespaces
    if ( $type =~ s/^\+// )
    {
        push @classes, $type;
    }
    foreach my $ns ( @$field_ns, 'HTML::FormHandler::Field', 'HTML::FormHandlerX::Field' )
    {
        push @classes, $ns . "::" . $type;
    }
    # look for Field in possible namespaces
    my $class;
    foreach my $try ( @classes ) {
        last if $class = load_optional_class($try) ? $try : undef;
    }
    die "Could not load field class '$type' for field '$name'"
       unless $class;

    return $class;
}

sub _find_parent {
    my ( $self, $field_attr ) = @_;

    # parent and name correction for names with dots
    my $parent;
    if ( $field_attr->{name} =~ /\./ ) {
        my @names       = split /\./, $field_attr->{name};
        my $simple_name = pop @names;
        my $parent_name = join '.', @names;
        # use special 'field' method call that starts from
        # $self, because names aren't always starting from
        # the form
        $parent      = $self->field($parent_name, undef, $self);
        if ($parent) {
            die "The parent of field " . $field_attr->{name} . " is not a Compound Field"
                unless $parent->isa('HTML::FormHandler::Field::Compound');
            $field_attr->{name}   = $simple_name;
        }
        else {
            die "did not find parent for field " . $field_attr->{name};
        }
    }
    elsif ( !( $self->form && $self == $self->form ) ) {
        # set parent
        $parent = $self;
    }

    # get full_name
    my $full_name = $field_attr->{name};
    $full_name = $parent->full_name . "." . $field_attr->{name}
        if $parent;
    $field_attr->{full_name} = $full_name;
    return $parent;

}

sub _merge_updates {
    my ( $self, $field_attr, $class ) = @_;

    # If there are field_traits at the form level, prepend them
    my $field_updates;
    unshift @{$field_attr->{traits}}, @{$self->form->field_traits} if $self->form;
    # use full_name for updates from form, name for updates from compound field
    my $full_name = delete $field_attr->{full_name} || $field_attr->{name};
    my $name = $field_attr->{name};

    my $single_updates = {}; # updates that apply to a single field
    my $all_updates = {};    # updates that apply to all fields
    # get updates from form update_subfields and widget_tags
    if ( $self->form ) {
        $field_updates = $self->form->update_subfields;
        if ( keys %$field_updates ) {
            $all_updates = $field_updates->{all} || {};
            $single_updates = $field_updates->{$full_name};
            if ( exists $field_updates->{by_flag} ) {
                $all_updates = $self->by_flag_updates(  $field_attr, $class, $field_updates, $all_updates );
            }
            if ( exists $field_updates->{by_type} &&
                 exists $field_updates->{by_type}->{$field_attr->{type}} ) {
                $all_updates = merge( $field_updates->{by_type}->{$field_attr->{type}}, $all_updates );
            }
        }
        # merge widget tags into 'all' updates
        if( $self->form->has_widget_tags ) {
            $all_updates = merge( $all_updates, { tags => $self->form->widget_tags } );
        }
    }
    # get updates from compound field update_subfields and widget_tags
    if ( $self->has_flag('is_compound') ) {
        my $comp_field_updates = $self->update_subfields;
        my $comp_all_updates = {};
        my $comp_single_updates = {};
        # -- compound 'all' updates --
        if ( keys %$comp_field_updates ) {
            $comp_all_updates = $comp_field_updates->{all} || {};
            # don't use full_name. varies depending on parent field name
            $comp_single_updates = $comp_field_updates->{$name} || {};
            if ( exists $field_updates->{by_flag} ) {
                $comp_all_updates = $self->by_flag_updates(  $field_attr, $class, $comp_field_updates, $comp_all_updates );
            }
            if ( exists $comp_field_updates->{by_type} &&
                 exists $comp_field_updates->{by_type}->{$field_attr->{type}} ) {
                $comp_all_updates = merge( $comp_field_updates->{by_type}->{$field_attr->{type}}, $comp_all_updates );
            }
        }
        if( $self->has_widget_tags ) {
            $comp_all_updates = merge( $comp_all_updates, { tags => $self->widget_tags } );
        }

        # merge form 'all' updates, compound field higher precedence
        $all_updates = merge( $comp_all_updates, $all_updates )
            if keys %$comp_all_updates;
        # merge single field updates, compound field higher precedence
        $single_updates = merge( $comp_single_updates, $single_updates )
            if keys %$comp_single_updates;
    }

    # attributes set on a specific field through update_subfields override has_fields
    # attributes set by 'all' only happen if no field attributes
    $field_attr = merge( $field_attr, $all_updates ) if keys %$all_updates;
    $field_attr = merge( $single_updates, $field_attr ) if keys %$single_updates;

    # get the widget and widget_wrapper from form
    unless( $self->form && $self->form->no_widgets ) {
        # widget
        my $widget = $field_attr->{widget};
        unless( $widget ) {
            my $attr = $class->meta->find_attribute_by_name( 'widget' );
            $widget = $attr->default if $attr;
        }
        $widget = '' if $widget eq 'None';
        # widget wrapper
        my $widget_wrapper = $field_attr->{widget_wrapper};
        unless( $widget_wrapper ) {
            my $attr = $class->meta->get_attribute('widget_wrapper');
            $widget_wrapper = $attr->default if $attr;
            $widget_wrapper ||= $self->form->widget_wrapper if $self->form;
            $widget_wrapper ||= 'Simple';
            $field_attr->{widget_wrapper} = $widget_wrapper;
        }
        # add widget and wrapper roles to field traits
        if ( $widget ) {
            my $widget_role = $self->get_widget_role( $widget, 'Field' );
            push @{$field_attr->{traits}}, $widget_role;
        }
        if ( $widget_wrapper ) {
            my $wrapper_role = $self->get_widget_role( $widget_wrapper, 'Wrapper' );
            push @{$field_attr->{traits}}, $wrapper_role;
        }
    }
    return $field_attr;
}

sub by_flag_updates {
    my ( $self, $field_attr, $class, $field_updates, $all_updates ) = @_;

    my $by_flag = $field_updates->{by_flag};
    if ( exists $by_flag->{contains} && $field_attr->{is_contains} ) {
        $all_updates = merge( $field_updates->{by_flag}->{contains}, $all_updates );
    }
    elsif ( exists $by_flag->{repeatable} && $class->meta->find_attribute_by_name('is_repeatable') ) {
        $all_updates = merge( $field_updates->{by_flag}->{repeatable}, $all_updates );
    }
    elsif ( exists $by_flag->{compound} && $class->meta->find_attribute_by_name('is_compound') ) {
        $all_updates = merge( $field_updates->{by_flag}->{compound}, $all_updates );
    }
    return $all_updates;
}

# update, replace, or create field
# Create makes the field object and passes in the properties as constructor args.
# Update changed properties on a previously created object.
# Replace overwrites a field with a different configuration.
# (The update/replace business is much the same as you'd see with inheritance.)
# This function populates/updates the base object's 'field' array.
sub _update_or_create {
    my ( $self, $parent, $field_attr, $class, $do_update ) = @_;

    $parent ||= $self->form;
    $field_attr->{parent} = $parent;
    $field_attr->{form} = $self->form if $self->form;
    my $index = $parent->field_index( $field_attr->{name} );
    my $field;
    if ( defined $index ) {
        if ($do_update)    # this field started with '+'. Update.
        {
            $field = $parent->field( $field_attr->{name} );
            die "Field to update for " . $field_attr->{name} . " not found"
                unless $field;
            foreach my $key ( keys %{$field_attr} ) {
                next if $key eq 'name' || $key eq 'form' || $key eq 'parent' ||
                    $key eq 'full_name' || $key eq 'type';
                $field->$key( $field_attr->{$key} )
                    if $field->can($key);
            }
        }
        else               # replace existing field
        {
            $field = $self->new_field_with_traits( $class, $field_attr);
            $parent->set_field_at( $index, $field );
        }
    }
    else                   # new field
    {
        $field = $self->new_field_with_traits( $class, $field_attr);
        $parent->add_field($field);
    }
    $field->form->add_repeatable_field($field)
        if ( $field->form && $field->has_flag('is_repeatable') );
    return $field;
}

sub new_field_with_traits {
    my ( $self, $class, $field_attr ) = @_;

    my $traits = delete $field_attr->{traits} || [];
    if( @$traits ) {
        $class = $class->with_traits( @$traits );
    }
    my $field = $class->new( %{$field_attr} );

    return $field;
}

sub _order_fields {
    my $self = shift;

    # order the fields
    # There's a hole in this... if child fields are defined at
    # a level above the containing parent, then they won't
    # exist when this routine is called and won't be ordered.
    # This probably needs to be moved out of here into
    # a separate recursive step that's called after build_fields.

    # get highest order number
    my $order = 0;
    foreach my $field ( $self->all_fields ) {
        $order++ if $field->order > $order;
    }
    $order++;
    # number all unordered fields
    foreach my $field ( $self->all_fields ) {
        $field->order($order) unless $field->order;
        $order++;
    }
}

use namespace::autoclean;
1;
