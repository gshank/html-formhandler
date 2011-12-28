package HTML::FormHandler::TraitFor::Types;
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

no Moose::Util::TypeConstraints;
1;
