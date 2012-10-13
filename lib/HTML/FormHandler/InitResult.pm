package HTML::FormHandler::InitResult;
# ABSTRACT: internal code

use Moose::Role;

=head1 SYNOPSIS

Internal role for initializing the result objects.

=cut

# _init is for building fields when
# there is no initial object and no params
# formerly _init
sub _result_from_fields {
    my ( $self, $self_result ) = @_;

    # defaults for compounds, etc.
    if ( my @values = $self->get_default_value ) {
        my $value = @values > 1 ? \@values : shift @values;
        if( ref $value eq 'HASH' || blessed $value ) {
            return $self->_result_from_object( $self_result, $value );
        }
        $self->init_value($value)   if defined $value;
        $self_result->_set_value($value) if defined $value;
    }
    my $my_value;
    for my $field ( $self->sorted_fields ) {
        next if ($field->inactive && !$field->_active);
        my $result = HTML::FormHandler::Field::Result->new(
            name   => $field->name,
            parent => $self_result
        );
        $result = $field->_result_from_fields($result);
        $my_value->{ $field->name } = $result->value if $result->has_value;
        $self_result->add_result($result) if $result;
    }
    # setting value here to handle disabled compound fields, where we want to
    # preserve the 'value' because the fields aren't submitted...except for the
    # form. Not sure it's the best idea to skip for form, but it maintains previous behavior
    $self_result->_set_value($my_value) if ( keys %$my_value );
    $self->_set_result($self_result);
    $self_result->_set_field_def($self) if $self->DOES('HTML::FormHandler::Field');
    return $self_result;
}

# building fields from input (params)
# formerly done in validate_field
sub _result_from_input {
    my ( $self, $self_result, $input, $exists ) = @_;

    # transfer the input values to the input attributes of the
    # subfields
    return unless ( defined $input || $exists || $self->has_fields );
    $self_result->_set_input($input);
    if ( ref $input eq 'HASH' ) {
        foreach my $field ( $self->sorted_fields ) {
            next if ($field->inactive && !$field->_active);
            my $field_name = $field->name;
            my $result     = HTML::FormHandler::Field::Result->new(
                name   => $field_name,
                parent => $self_result
            );
            my $exists = exists $input->{$field->input_param || $field_name};
            $result =
                $field->_result_from_input( $result, $input->{$field->input_param || $field_name},
                $exists );
            $self_result->add_result($result) if $result;
        }
    }
    $self->_set_result($self_result);
    $self_result->_set_field_def($self) if $self->DOES('HTML::FormHandler::Field');
    return $self_result;
}

# building fields from model object or init_obj hash
# formerly _init_from_object
sub _result_from_object {
    my ( $self, $self_result, $item ) = @_;

    return unless ( $item || $self->has_fields );    # empty fields for compounds
    my $my_value;
    for my $field ( $self->sorted_fields ) {
        next if ( $field->inactive && !$field->_active );
        my $result = HTML::FormHandler::Field::Result->new(
            name   => $field->name,
            parent => $self_result
        );
        if ( (ref $item eq 'HASH' && !exists $item->{ $field->accessor } ) ||
             ( blessed($item) && !$item->can($field->accessor) ) ) {
            $result = $field->_result_from_fields($result);
        }
        else {
           my $value = $self->_get_value( $field, $item );
           $result = $field->_result_from_object( $result, $value );
        }
        $self_result->add_result($result) if $result;
        $my_value->{ $field->name } = $field->value;
    }
    $self_result->_set_value($my_value);
    $self->_set_result($self_result);
    $self_result->_set_field_def($self) if $self->DOES('HTML::FormHandler::Field');
    return $self_result;
}

sub find_sub_item {
    my ( $self, $item, $field_name_array ) = @_;
    my $this_fname = shift @$field_name_array;;
    my $field = $self->field($this_fname);
    my $new_item = $self->_get_value( $field, $item );
    if ( scalar @$field_name_array ) {
        $new_item = $field->find_sub_item( $new_item, $field_name_array );
    }
    return $new_item;
}

sub _get_value {
    my ( $self, $field, $item ) = @_;

    my $accessor = $field->accessor;
    my @values;
    if( defined $field->default_over_obj ) {
        @values = $field->default_over_obj;
    }
    elsif( $field->form && $field->form->use_defaults_over_obj && ( @values = $field->get_default_value )  ) {
    }
    elsif ( blessed($item) && $item->can($accessor) ) {
        my $v = $item->$accessor;
        if($field->has_flag('multiple') && ref($v) eq 'ARRAY'){
            @values = @$v;
        } else {
            @values = $v;
        }
    }
    elsif ( exists $item->{$accessor} ) {
        my $v = $item->{$accessor};
        if($field->has_flag('multiple') && ref($v) eq 'ARRAY'){
            @values = @$v;
        } else {
            @values = $v;
        }
    }
    elsif ( @values = $field->get_default_value ) {
    }
    else {
        return;
    }
    if( $field->has_inflate_default_method ) {
        @values = $field->inflate_default(@values);
    }
    my $value;
    if( $field->has_flag('multiple')) {
        $value = scalar @values == 1 && ! defined $values[0] ? [] : \@values;
    }
    else {
        $value = @values > 1 ? \@values : shift @values;
    }
    return $value;
}

use namespace::autoclean;
1;
