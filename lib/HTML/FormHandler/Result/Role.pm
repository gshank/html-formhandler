package HTML::FormHandler::Result::Role;

use Moose::Role;

=head1 NAME

HTML::FormHandler::Role::Result

=head1 SYNOPSIS

Role to hold common result attributes for L<HTML::FormHandler::Result>
and L<HTML::FormHandler::Result::Field>.

=cut

has 'name' => ( isa => 'Str', is => 'rw', required => 1 );

# do we need 'accessor' ?
has 'parent' => ( is =>'rw', weak_ref => 1 );

has 'input' => (
   is        => 'ro',
   clearer   => '_clear_input',
   writer    => '_set_input',
   predicate => 'has_input',
);
   
has 'value' => (
   is        => 'ro',
   writer    => '_set_value',
   clearer   => '_clear_value',
   predicate => 'has_value',
);

has 'results'     => (
   metaclass  => 'Collection::Array',
   isa        => 'ArrayRef[HTML::FormHandler::Field::Result]',
   is         => 'rw',
   auto_deref => 1,
   default    => sub { [] },
   provides   => {
      'push'  => 'add_result',
      'count' => 'num_results',
      'empty' => 'has_results',
      'clear' => 'clear_results',
   }
);

has 'error_results' => (
   metaclass  => 'Collection::Array',
   isa        => 'ArrayRef', # for HFH::Result and HFH::Field::Result
   is         => 'rw',
   default    => sub { [] },
   provides   => {
      empty => 'has_error_results',
      clear => 'clear_error_results',
      push  => 'add_error_result',
      count => 'num_error_results'
   }
);

has 'errors'     => (
   metaclass  => 'Collection::Array',
   isa        => 'ArrayRef[Str]',
   is         => 'rw',
   auto_deref => 1,
   default    => sub { [] },
   provides   => {
      'push'  => 'push_errors',
      'count' => 'num_errors',
      'empty' => 'has_errors',
      'clear' => 'clear_errors',
   }
);

sub validated { !$_[0]->has_error_results && $_[0]->has_input  }
# sub ran_validation { shift->has_input }

sub field
{
   my ( $self, $name, $die ) = @_;

   my $index;
   # if this is a full_name for a compound field
   # walk through the fields to get to it
   if ( $name =~ /\./ ) {
      my @names = split /\./, $name;
      my $f = $self;
      foreach my $fname (@names) {
         $f = $f->field($fname);
         return unless $f;
      }
      return $f;
   }
   else    # not a compound name
   {
      for my $field ( $self->results ) {
         return $field if ( $field->name eq $name );
      }
   }
   return unless $die;
   die "Field '$name' not found in '$self'";
}

=head1 AUTHORS

HTML::FormHandler Contributors; see HTML::FormHandler

Initially based on the original source code of L<Form::Processor::Field> by Bill Moseley

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

no Moose::Role;
1;
