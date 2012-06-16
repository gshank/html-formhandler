package HTML::FormHandler::Validate;
# ABSTRACT: validation role (internal)

=head1 SYNOPSIS

This is a role that contains validation and transformation code
used by L<HTML::FormHandler::Field>.

=cut

use Moose::Role;
use Carp;

has 'required' => ( isa => 'Bool', is => 'rw', default => '0' );
has 'required_when' => ( is => 'rw', isa => 'HashRef', predicate => 'has_required_when' );
has 'required_message' => (
    isa     => 'ArrayRef|Str',
    is      => 'rw',
);
has 'unique'            => ( isa => 'Bool', is => 'rw', predicate => 'has_unique' );
has 'unique_message'    => ( isa => 'Str',  is => 'rw' );
has 'range_start' => ( isa => 'Int|Undef', is => 'rw' );
has 'range_end'   => ( isa => 'Int|Undef', is => 'rw' );

sub test_ranges {
    my $field = shift;
    return 1 if $field->can('options') || $field->has_errors;

    my $value = $field->value;

    return 1 unless defined $value;

    my $low  = $field->range_start;
    my $high = $field->range_end;

    if ( defined $low && defined $high ) {
        return
            $value >= $low && $value <= $high ? 1 :
              $field->add_error( $field->get_message('range_incorrect'), $low, $high );
    }

    if ( defined $low ) {
        return
            $value >= $low ? 1 :
              $field->add_error( $field->get_message('range_too_low'), $low );
    }

    if ( defined $high ) {
        return
            $value <= $high ? 1 :
              $field->add_error( $field->get_message('range_too_high'), $high );
    }

    return 1;
}

sub validate_field {
    my $field = shift;

    return unless $field->has_result;
    $field->clear_errors;    # this is only here for testing convenience
                             # See if anything was submitted
    my $continue_validation = 1;
    if ( ( $field->required ||
           ( $field->has_required_when && $field->match_when($field->required_when) ) ) &&
       ( !$field->has_input || !$field->input_defined ) ) {
        $field->add_error( $field->get_message('required'), $field->loc_label );
        if( $field->has_input ) {
           $field->not_nullable ? $field->_set_value($field->input) : $field->_set_value(undef);
        }
        $continue_validation = 0;
    }
    elsif ( $field->DOES('HTML::FormHandler::Field::Repeatable') ) { }
    elsif ( !$field->has_input ) {
        $continue_validation = 0;
    }
    elsif ( !$field->input_defined ) {
        if ( $field->not_nullable ) {
            $field->_set_value($field->input);
        }
        elsif ( $field->no_value_if_empty || $field->has_flag('is_contains') ) {
        }
        else {
            $field->_set_value(undef);
        }
        $continue_validation = 0;
    }
    return if ( !$continue_validation && !$field->validate_when_empty );

    # do building of node
    if ( $field->DOES('HTML::FormHandler::Fields') ) {
        $field->_fields_validate;
    }
    else {
        my $input = $field->input;
        $input = $field->inflate( $input ) if $field->has_inflate_method;
        $field->_set_value( $input );
    }

    $field->_inner_validate_field();
    $field->_apply_actions;
    $field->validate;
    $field->test_ranges;
    $field->_validate($field)    # form field validation method
        if ( $field->has_value && defined $field->value );
    # validation done, if everything validated, do deflate_value for
    # final $form->value
    if( $field->has_deflate_value_method && !$field->has_errors ) {
        $field->_set_value( $field->deflate_value($field->value) );
    }

    return !$field->has_errors;
}

sub _inner_validate_field { }

sub validate { 1 }

has 'actions' => (
    traits     => ['Array'],
    isa        => 'ArrayRef',
    is         => 'rw',
    default    => sub { [] },
    handles   => {
        add_action => 'push',
        num_actions =>'count',
        has_actions => 'count',
        clear_actions => 'clear',
    }
);

sub _build_apply_list {
    my $self = shift;
    my @apply_list;
    foreach my $sc ( reverse $self->meta->linearized_isa ) {
        my $meta = $sc->meta;
        if ( $meta->can('calculate_all_roles') ) {
            foreach my $role ( $meta->calculate_all_roles ) {
                if ( $role->can('apply_list') && $role->has_apply_list ) {
                    foreach my $apply_def ( @{ $role->apply_list } ) {
                        my %new_apply = %{$apply_def};    # copy hashref
                        push @apply_list, \%new_apply;
                    }
                }
            }
        }
        if ( $meta->can('apply_list') && $meta->has_apply_list ) {
            foreach my $apply_def ( @{ $meta->apply_list } ) {
                my %new_apply = %{$apply_def};            # copy hashref
                push @apply_list, \%new_apply;
            }
        }
    }
    $self->add_action(@apply_list);
}

sub _apply_actions {
    my $self = shift;

    my $error_message;
    local $SIG{__WARN__} = sub {
        my $error = shift;
        $error_message = $error;
        return 1;
    };
    for my $action ( @{ $self->actions || [] } ) {
        $error_message = undef;
        # the first time through value == input
        my $value     = $self->value;
        my $new_value = $value;
        # Moose constraints
        if ( !ref $action || ref $action eq 'MooseX::Types::TypeDecorator' ) {
            $action = { type => $action };
        }
        if ( my $when = $action->{when} ) {
            next unless $self->match_when($when);
        }
        if ( exists $action->{type} ) {
            my $tobj;
            if ( ref $action->{type} eq 'MooseX::Types::TypeDecorator' ) {
                $tobj = $action->{type};
            }
            else {
                my $type = $action->{type};
                $tobj = Moose::Util::TypeConstraints::find_type_constraint($type) or
                    die "Cannot find type constraint $type";
            }
            if ( $tobj->has_coercion && $tobj->validate($value) ) {
                eval { $new_value = $tobj->coerce($value) };
                if ($@) {
                    if ( $tobj->has_message ) {
                        $error_message = $tobj->message->($value);
                    }
                    else {
                        $error_message = $@;
                    }
                }
                else {
                    $self->_set_value($new_value);
                }

            }
            $error_message ||= $tobj->validate($new_value);
        }
        # now maybe: http://search.cpan.org/~rgarcia/perl-5.10.0/pod/perlsyn.pod#Smart_matching_in_detail
        # actions in a hashref
        elsif ( ref $action->{check} eq 'CODE' ) {
            if ( !$action->{check}->($value, $self) ) {
                $error_message = $self->get_message('wrong_value');
            }
        }
        elsif ( ref $action->{check} eq 'Regexp' ) {
            if ( $value !~ $action->{check} ) {
                $error_message = [$self->get_message('no_match'), $value];
            }
        }
        elsif ( ref $action->{check} eq 'ARRAY' ) {
            if ( !grep { $value eq $_ } @{ $action->{check} } ) {
                $error_message = [$self->get_message('not_allowed'), $value];
            }
        }
        elsif ( ref $action->{transform} eq 'CODE' ) {
            $new_value = eval {
                no warnings 'all';
                $action->{transform}->($value, $self);
            };
            if ($@) {
                $error_message = $@ || $self->get_message('error_occurred');
            }
            else {
                $self->_set_value($new_value);
            }
        }
        if ( defined $error_message ) {
            my @message = ref $error_message eq 'ARRAY' ? @$error_message : ($error_message);
            if ( defined $action->{message} ) {
                my $act_msg = $action->{message};
                if ( ref $act_msg eq 'CODE' ) {
                    $act_msg = $act_msg->($value, $self, $error_message);
                }
                if ( ref $act_msg eq 'ARRAY' ) {
                    @message = @{$act_msg};
                }
                elsif ( ref \$act_msg eq 'SCALAR' ) {
                    @message = ($act_msg);
                }
            }
            $self->add_error(@message);
        }
    }
}

sub match_when {
    my ( $self, $when ) = @_;

    my $matched = 0;
    foreach my $key ( keys %$when ) {
        my $check_against = $when->{$key};
        my $from_form = ( $key =~ /^\+/ );
        $key =~ s/^\+//;
        my $field = $from_form ? $self->form->field($key) : $self->parent->subfield( $key );
        unless ( $field ) {
            warn "field '$key' not found processing when";
            next;
        }
        if ( ref $check_against eq 'CODE' ) {
            $matched++
                if $check_against->($field->fif, $self);
        }
        elsif ( ref $check_against eq 'ARRAY' ) {
            foreach my $value ( @$check_against ) {
                $matched++ if ( $value eq $field->fif );
            }
        }
        elsif ( $check_against eq ( $field->fif || '' ) ) {
            $matched++;
        }
        else {
            $matched = 0;
            last;
        }
    }
    return $matched;
}

use namespace::autoclean;
1;

