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

    # if the 'fields_for_input_without_param' flag is set, and the field doesn't have input,
    # copy the value to the input.
    if ( !$field->has_input && $field->form && $field->form->use_fields_for_input_without_param ) {
        $field->result->_set_input($field->value);
    }
    # handle required and required_when processing, and transfer input to value
    my $continue_validation = 1;
    if ( ( $field->required ||
           ( $field->has_required_when && $field->match_when($field->required_when) ) ) &&
       ( !$field->has_input || !$field->input_defined ) ) {
        $field->missing(1);
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
            # handles the case where a compound field value needs to have empty subfields
            $continue_validation = 0 unless $field->has_flag('is_compound');
        }
        elsif ( $field->no_value_if_empty || $field->has_flag('is_contains') ) {
            $continue_validation = 0;
        }
        else {
            $field->_set_value(undef);
            $continue_validation = 0;
        }
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
    $field->validate( $field->value );
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


# Locale::Maketext compiles its FORMAT argument: a '[...]' group in it becomes
# method-dispatch code (see _compile in Locale::Maketext). Messages FormHandler
# itself authors are templates on purpose, but several kinds of text reaching
# _apply_actions are not ours and do carry request data -- a warning trapped by
# the $SIG{__WARN__} handler below (Perl quotes the offending value into it
# verbatim), a type constraint's failure message (the type system renders a
# rejected reference in bracket-and-comma form), and exceptions from a coercion
# or a transform.
#
# Rather than escape the bracket metacharacters in such text, hand it to the
# localizer as an ARGUMENT with a constant format, which is the idiom the
# add_error POD recommends to applications: the text then cannot be parsed as
# anything at all, so there is no escaping to get right.
#
# This applies to all such text, not only text that happens to contain a
# bracket. Two reasons. It keeps the rule simple enough to check by reading it
# -- "text we did not author is never a format" -- with no predicate to get
# wrong. And it stops the text being used as a LEXICON KEY: with _AUTO set, as
# it is for HTML::FormHandler::I18N::en_us, Locale::Maketext memoises every
# distinct format into a package-global hash that is never evicted and outlives
# the handle, so distinct submitted values otherwise accumulate in a long-lived
# process for as long as it runs.
#
# The cost is that such text is no longer looked up in the lexicon, so a
# translated custom type-constraint message is now shown as the type gave it.
# A maintainer who would rather keep that lookup can return false for text with
# no '~', '[' or ']' in it, which is the complete set of characters
# Locale::Maketext's compiler treats specially:
#
#     return 0 if $text !~ /[~\[\]]/;
#
# and adjust the corresponding assertion in t/errors/maketext_inert_argument.t.
# References are diverted too, and deliberately so. All of the sources above can
# deliver one: `warn $object` hands the object itself to $SIG{__WARN__}, `die
# $object` in a transform or a coercion leaves it in $@, and a type constraint's
# message block may return one. Locale::Maketext then STRINGIFIES whatever it is
# given as the format -- _compile's own fast-path regex does it before anything
# else -- so an object with a '""' overload that yields bracket notation would
# skip a reference bailout and be compiled anyway. Testing the stringification
# here instead would not help: Maketext performs its own, later stringification,
# so inspecting one and compiling the other leaves a gap, and an overload is
# arbitrary code that need not answer the same way twice. Passing the object as
# an argument sidesteps all of it -- an argument is interpolated, never compiled,
# so it stringifies exactly as it did before and only the compilation is gone.
sub _needs_inert_format {
    my ( $self, $text ) = @_;

    return defined $text ? 1 : 0;
}
sub _apply_actions {
    my $self = shift;

    my $error_message;
    # True when $error_message holds text this module did not author.
    my $foreign_message;
    local $SIG{__WARN__} = sub {
        my $error = shift;
        $error_message   = $error;
        $foreign_message = 1;
        return 1;
    };

    my $is_type = sub {
        my $class = blessed shift or return;
        return $class eq 'MooseX::Types::TypeDecorator' || $class->isa('Type::Tiny');
    };

    for my $action ( @{ $self->actions || [] } ) {
        $error_message   = undef;
        $foreign_message = undef;
        # the first time through value == input
        my $value     = $self->value;
        my $new_value = $value;
        # Moose constraints
        if ( !ref $action || $is_type->($action) ) {
            $action = { type => $action };
        }
        if ( my $when = $action->{when} ) {
            next unless $self->match_when($when);
        }
        if ( exists $action->{type} ) {
            my $tobj;
            if ( $is_type->($action->{type}) ) {
                $tobj = $action->{type};
            }
            else {
                my $type = $action->{type};
                $tobj = Moose::Util::TypeConstraints::find_type_constraint($type) or
                    die "Cannot find type constraint $type";
            }
            if ( $tobj->has_coercion && $tobj->validate($value) ) {
                my $coerce_returned = eval { $tobj->coerce($value) };
                if ($@) {
                    if ( $tobj->has_message ) {
                        $error_message = $tobj->message->($value);
                    }
                    else {
                        $error_message = $@;
                    }
                    $foreign_message = 1;
                }
                else {
                    $new_value = $coerce_returned;
                    $self->_set_value($new_value);
                }

            }
            unless ($error_message) {
                $error_message = $tobj->validate($new_value);
                $foreign_message = 1 if $error_message;
            }
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
                $foreign_message = 1;
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
                # The application supplied this message, so it is a template on
                # purpose and foreignness no longer applies.
                $foreign_message = 0;
            }
            if ( $foreign_message && $self->_needs_inert_format( $message[0] ) ) {
                # Interpolate explicitly. A format that is a single bracket group
                # compiles to one chunk, and Locale::Maketext only prepends its
                # `join ''` when there is more than one, so '[_1]' alone returns the
                # argument UNCHANGED rather than a string -- which would put an
                # exception object into the errors attribute, where the type
                # constraint is ArrayRef[Str]. Stringifying here also means the
                # conversion happens exactly once, under our control, and its result
                # can never be reparsed as a format.
                @message = ( '[_1]', "$message[0]" );
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
            warn "field '$key' not found processing 'when' for '" . $self->full_name . "'";
            next;
        }
        my $field_fif = defined $field->fif ? $field->fif : '';
        if ( ref $check_against eq 'CODE' ) {
            $matched++
                if $check_against->($field_fif, $self);
        }
        elsif ( ref $check_against eq 'ARRAY' ) {
            foreach my $value ( @$check_against ) {
                $matched++ if ( $value eq $field_fif );
            }
        }
        elsif ( $check_against eq $field_fif ) {
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

