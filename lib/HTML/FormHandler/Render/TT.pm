package HTML::FormHandler::Render::TT;

use Moose;
use Template;
use Data::Section -setup;

=head1 NAME

HTML::FormHandler::Render::TT;

=head1 SYNOPSIS

  use HTML::FormHandler::Render::TT; 


=head2 merged_section_data

returns hash containing all messages 

=head2 message

returns string containing message

=cut

sub get
{
   my ( $self, $name, @args ) =  @_;

   # following is a string REFERENCE
   my $message = $self->section_data($name);
   if ( @args > 1 )
   {
      my $tt_message = $self->fill_in($message, @args);
      $message = \$tt_message;
   }
   die "Could not retrieve message $name" unless $message;
   return ${$message};
}

sub fill_in
{
   my ( $self, $template, @args ) = @_;
   my $tt = Template->new;
   my $output;
   $tt->process( $template, {@args}, \$output); 
   return $output;
}

1;
__DATA__
__[ test_msg ]__
This is a test
__[ test_with_vars ]__
This is the [% test %] test
