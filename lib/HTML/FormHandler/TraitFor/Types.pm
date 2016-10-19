package HTML::FormHandler::TraitFor::Types;
# ABSTRACT: types used internally in FormHandler

use Moose::Role;
use Moose::Util::TypeConstraints;

subtype 'HFH::ArrayRefStr'
  => as 'ArrayRef[Str]';

coerce 'HFH::ArrayRefStr'
  => from 'Str'
  => via {
         if( length $_ ) { return [$_] };
         return [];
     };

coerce 'HFH::ArrayRefStr'
  => from 'Undef'
  => via { return []; };

subtype 'HFH::SelectOptions'
  => as 'ArrayRef[HashRef]';

coerce 'HFH::SelectOptions'
  => from 'ArrayRef[Str]'
  => via {
         my @options = @$_;
         die "Options array must contain an even number of elements"
            if @options % 2;
         my $opts;
         push @{$opts}, { value => shift @options, label => shift @options } while @options;
         return $opts;
     };

coerce 'HFH::SelectOptions'
  => from 'ArrayRef[ArrayRef]'
  => via {
         my @options = @{ $_[0][0] };
         my $opts;
         push @{$opts}, { value => $_, label => $_ } foreach @options;
         return $opts;
     };

no Moose::Util::TypeConstraints;
1;
