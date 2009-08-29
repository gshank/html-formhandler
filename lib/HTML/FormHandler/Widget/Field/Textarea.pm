package HTML::FormHandler::Widget::Field::Textarea;

use Moose::Role;

sub render
{
   my ( $self, $result ) = @_;

   $result ||= $self->result;
   my $fif  = $self->fif($result) || '';
   my $id   = $self->id;
   my $cols = $self->cols || 10;
   my $rows = $self->rows || 5;
   my $name = $self->html_name;

   my $output =
      qq(<textarea name="$name" id="$id" ) . qq(rows="$rows" cols="$cols">$fif</textarea>);

   return $self->render_field($result, $output);
}

1;
