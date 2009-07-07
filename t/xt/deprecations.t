use strict;
use warnings;
use Test::More;

BEGIN { 
   eval "use Perl::Critic";
   plan skip_all => 'Perl::Critic required' if $@;
   plan tests => 2;
}
my $critic = Perl::Critic->new( -theme => 'formhandler' );
my @violations = $critic->critique( 't/var/MyForm.pm');
is( $violations[0]->description, 'The "min_length" attribute used', 'min_length in has_field' );
@violations = $critic->critique( 't/var/MyField.pm');
is( $violations[0]->description, 'The "min_length" attribute used', '+min_length in field def' );

