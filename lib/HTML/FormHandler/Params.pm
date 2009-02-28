package    # hide from Pause
   HTML::FormHandler::Params;

use strict;
use warnings;
use Carp;

sub separator { '.' }
sub max_array { 100 }
sub split_name
{
   my ( $class, $name, $sep ) = @_;

   $sep ||= $class->separator();
   $sep = "\Q$sep";

   if( $sep eq '[]' )
   {
      return grep { defined } ( $name =~ /
         ^ (\w+)        # root param
         | \[ (\w+) \]  # nested
         /gx );
   }

   # These next two regexes are the escaping aware equivalent
   # to the following:
   # my ($first, @segments) = split(/\./, $name, -1);

   # m// splits on unescaped '.' chars. Can't fail b/c \G on next
   # non ./ * -> escaped anything -> non ./ *
   $name =~ m/^ ( [^\\$sep]* (?: \\(?:.|$) [^\\$sep]* )* ) /gx;
   my $first = $1;
   $first =~ s/\\(.)/$1/g;    # remove escaping

   my (@segments) = $name =~
      # . -> ( non ./ * -> escaped anything -> non ./ * )
      m/\G (?:[$sep]) ( [^\\$sep]* (?: \\(?:.|$) [^\\$sep]* )* ) /gx;
   # Escapes removed later, can be used to avoid using as array index

   return ( $first, @segments );
}


sub expand_hash
{
   my ( $class, $flat, $sep ) = @_;

   my $deep = {};
   $sep  ||= $class->separator;

   for my $name ( keys %$flat )
   {

      my ( $first, @segments ) = $class->split_name($name, $sep);

      my $box_ref = \$deep->{$first};
      for (@segments)
      {
         if ( $class->max_array && /^(0|[1-9]\d*)$/ )
         {
            croak "HFH: param array limit exceeded $1 for $name=$_"
               if ( $1 >= $class->max_array );
            $$box_ref = [] unless defined $$box_ref;
            croak "HFH: param clash for $name=$_"
               unless ref $$box_ref eq 'ARRAY';
            $box_ref = \( $$box_ref->[$1] );
         }
         else
         {
            s/\\(.)/$1/g if $sep;    # remove escaping
            $$box_ref = {} unless defined $$box_ref;
            croak "HFH: param clash for $name=$_"
               unless ref $$box_ref eq 'HASH';
            $box_ref = \( $$box_ref->{$_} );
         }
      }
      croak "HFH: param clash for $name value $flat->{$name}"
         if defined $$box_ref;
      $$box_ref = $flat->{$name};
   }
   return $deep;
}

sub collapse_hash
{
   my $class = shift;
   my $deep  = shift;
   my $flat  = {};

   $class->_collapse_hash( $deep, $flat, () );
   return $flat;
}

sub join_name
{
   my ( $class, @array ) = @_;
   my $sep = substr( $class->separator, 0, 1 );
   return join $sep, @array;
}

sub _collapse_hash
{
   my ( $class, $deep, $flat, @segments ) = @_;

   if ( !ref $deep )
   {
      my $name = $class->join_name(@segments);
      $flat->{$name} = $deep;
   }
   elsif ( ref $deep eq 'HASH' )
   {
      for ( keys %$deep )
      {
         # escape \ and separator chars (once only, at this level)
         my $name = $_;
         if ( defined( my $sep = $class->separator ) )
         {
            $sep = "\Q$sep";
            $name =~ s/([\\$sep])/\\$1/g;
         }
         $class->_collapse_hash( $deep->{$_}, $flat, @segments, $name );
      }
   }
   elsif ( ref $deep eq 'ARRAY' )
   {
      croak "HFH: param array limit exceeded $#$deep for ", $class->join_name(@_)
         if ( $#$deep + 1 >= $class->max_array );
      for ( 0 .. $#$deep )
      {
         $class->_collapse_hash( $deep->[$_], $flat, @segments, $_ )
            if defined $deep->[$_];
      }
   }
   else
   {
      croak "Unknown reference type for ", $class->join_name(@segments), ":", ref $deep;
   }
}

1;
