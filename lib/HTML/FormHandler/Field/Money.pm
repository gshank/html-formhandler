package HTML::FormHandler::Field::Money;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';
our $VERSION = '0.01';

apply(  [ 
          { transform => sub { 
               my $value = shift; 
               $value =~ s/^\$//;
               return $value;
              } 
           },
           { transform => sub{ sprintf '%.2f', $_[0] },
              message => 'Value cannot be converted to money' 
           },
           { check => sub { $_[0] =~ /^-?\d+\.?\d*$/ },
             message => 'Value must be a real number'
           }
         ] );


=head1 NAME

HTML::FormHandler::Field::Money - Input US currenty-like values.

=head1 DESCRIPTION

Validates that a postive or negative real value is entered.
Formatted with two decimal places.

Uses a period for the decimal point. Widget type is 'text'. 

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
no HTML::FormHandler::Moose;
1;
