package HTML::FormHandler::Validate::Actions;

use Moose::Role;

=head1 NAME

FormHandler::Validate::Actions

=head1 SYNOPSIS

Role applies 'actions' (Moose types, coderefs, callbacks) to
L<HTML::FormHandler::Field> and L<HTML::FormHandler>.

=cut

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
            if ( !$action->{check}->($value) ) {
                $error_message = 'Wrong value';
            }
        }
        elsif ( ref $action->{check} eq 'Regexp' ) {
            if ( $value !~ $action->{check} ) {
                $error_message = ["[_1] does not match", $value];
            }
        }
        elsif ( ref $action->{check} eq 'ARRAY' ) {
            if ( !grep { $value eq $_ } @{ $action->{check} } ) {
                $error_message = ["[_1] not allowed", $value];
            }
        }
        elsif ( ref $action->{transform} eq 'CODE' ) {
            $new_value = eval {
                no warnings 'all';
                $action->{transform}->($value);
            };
            if ($@) {
                $error_message = $@ || 'error occurred';
            }
            else {
                $self->_set_value($new_value);
            }
        }
        if ( defined $error_message ) {
            my @message = ref $error_message eq 'ARRAY' ? @$error_message : ($error_message);
            if ( defined $action->{message} ) {
                my $act_msg = $action->{message};
                if ( ref $act_msg eq 'CODEREF' ) {
                    $act_msg = $act_msg->($value);
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

=head1 AUTHORS

HTML::FormHandler Contributors; see HTML::FormHandler

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

use namespace::autoclean;
1;
