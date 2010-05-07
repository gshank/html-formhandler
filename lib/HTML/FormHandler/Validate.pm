package HTML::FormHandler::Validate;

=head1 NAME

HTML::FormHandler::Validate

=head1 SYNOPSIS

This is a role that contains validation and transformation code
used by both L<HTML::FormHandler> and L<HTML::FormHandler::Field>.

=cut

use Moose::Role;
use Carp;

has 'required' => ( isa => 'Bool', is => 'rw', default => '0' );
has 'required_message' => (
    isa     => 'ArrayRef|Str',
    is      => 'rw',
    lazy    => 1,
    default => sub { 
        return [ '[_1] field is required', shift->loc_label ];
    }
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
              $field->add_error( 'value must be between [_1] and [_2]', $low, $high );
    }

    if ( defined $low ) {
        return
            $value >= $low ? 1 :
              $field->add_error( 'value must be greater than or equal to [_1]', $low );
    }

    if ( defined $high ) {
        return
            $value <= $high ? 1 :
              $field->add_error( 'value must be less than or equal to [_1]', $high );
    }

    return 1;
}

sub validate_field {
    my $field = shift;

    return unless $field->has_result;
    $field->clear_errors;    # this is only here for testing convenience
                             # See if anything was submitted
    if ( $field->required && ( !$field->has_input || !$field->input_defined ) ) {
        if ($field->required) {
            my $msg = $field->required_message;
            if ( ref $msg eq 'ARRAY' ) {
                $field->add_error( @$msg );
            }
            else {
                $field->add_error( $msg );
            }
        }
        if( $field->has_input ) {
           $field->not_nullable ? $field->_set_value($field->input) : $field->_set_value(undef);
        }
        return;
    }
    elsif ( $field->DOES('HTML::FormHandler::Field::Repeatable') ) { }
    elsif ( !$field->has_input ) {
        return;
    }
    elsif ( !$field->input_defined ) {
        $field->not_nullable ? $field->_set_value($field->input) : $field->_set_value(undef);
        return;
    }

    # do building of node
    if ( $field->DOES('HTML::FormHandler::Fields') ) {
        $field->_fields_validate;
    }
    else {
        $field->_set_value( $field->input );
    }

    $field->_inner_validate_field();
    $field->_apply_actions;
    $field->validate;
    $field->test_ranges;
    $field->_validate($field)    # form field validation method
        if ( $field->has_value && defined $field->value );

    return !$field->has_errors;
}

sub _inner_validate_field { }

sub validate { 1 }

=head1 AUTHORS

HTML::FormHandler Contributors; see HTML::FormHandler

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

use namespace::autoclean;
1;

