package HTML::FormHandler::TransformAndCheck;

=head1 NAME

HTML::FormHandler::TransformAndCheck

=head1 SYNOPSIS

This is a role that contains validation and transformation code
used by both L<HTML::FormHandler> and L<HTML::FormHandler::Field>.

=cut

use Moose::Role;
use Carp;

has 'input' => (
   is        => 'rw',
   clearer   => 'clear_input',
   predicate => 'has_input',
);
   
has 'value' => (
   is        => 'rw',
   clearer   => 'clear_value',
   predicate => 'has_value',
);
has 'required' => ( isa => 'Bool', is => 'rw', default => '0' );
has 'required_message' => (
   isa     => 'Str',
   is      => 'rw',
   lazy    => 1,
   default => sub { shift->label . ' field is required' }
);
has 'range_start' => ( isa => 'Int|Undef', is => 'rw', default => undef );
has 'range_end'   => ( isa => 'Int|Undef', is => 'rw', default => undef );
has 'actions'     => (
   metaclass  => 'Collection::Array',
   isa        => 'ArrayRef',
   is         => 'rw',
   auto_deref => 1,
   default    => sub { [] },
   provides   => {
      'push'  => 'add_action',
      'count' => 'num_actions',
      'empty' => 'has_actions',
      'clear' => 'clear_actions',
   }
);

sub test_ranges
{
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

sub _build_apply_list
{
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
            my %new_apply = %{$apply_def};          # copy hashref
            push @apply_list, \%new_apply;
         }
      }
   }
   $self->add_action(@apply_list);
}

sub has_some_value
{
   my $x = shift;

   return unless defined $x;
   return $x =~ /\S/ if !ref $x;
   if ( ref $x eq 'ARRAY' ) {
      for my $elem (@$x) {
         return 1 if has_some_value($elem);
      }
      return 0;
   }
   if ( ref $x eq 'HASH' ) {
      for my $key ( keys %$x ) {
         return 1 if has_some_value( $x->{$key} );
      }
      return 0;
   }
   return blessed $x;    # true if blessed, otherwise false
}

sub input_defined
{
   my ($self) = @_;
   return unless $self->has_input;
   return has_some_value( $self->input );
}

sub validate_field
{
   my $field = shift;

   $field->clear_errors;
   # See if anything was submitted
   if ( $field->required && ( !$field->has_input || !$field->input_defined ) ) {
      $field->add_error( $field->required_message ) if ( $field->required );
      $field->value(undef) if ( $field->has_input );
      return;
   }
   elsif ( $field->DOES('HTML::FormHandler::Field::Repeatable') ) { }
   elsif ( !$field->has_input ) {
      return;
   }
   elsif ( !$field->input_defined ) {
      $field->value(undef);
      return;
   }

   # do building of node
   if ( $field->DOES('HTML::FormHandler::Fields') ) {
      $field->process_node;
   }
   else {
      $field->value( $field->input );
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

sub _apply_actions
{
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
               $self->value($new_value);
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
            $error_message = "\"$value\" does not match";
         }
      }
      elsif ( ref $action->{check} eq 'ARRAY' ) {
         if ( !grep { $value eq $_ } @{ $action->{check} } ) {
            $error_message = "\"$value\" not allowed";
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
            $self->value($new_value);
         }
      }
      if ( defined $error_message ) {
         my @message = ($error_message);
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

sub validate { 1 }

=head1 AUTHORS

HTML::FormHandler Contributors; see HTML::FormHandler

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose::Role;
1;

