package HTML::FormHandler::Field::Display;

use Moose;
extends 'HTML::FormHandler::Field::NoValue';
use namespace::autoclean;

=head1 NAME

HTML::FormHandler::Field::Display 

=head1 SYNOPSIS

This class can be used for fields that are display only. It will
render the value returned by a form's 'html_<field_name>' method,
or the field's 'html' attribute.

  has_field 'explanation' => ( type => 'Display',
     html => '<p>This is an explanation...</p>' );

or in a form:

  has_field 'explanation' => ( type => 'Display' );
  sub html_explanation {
     my ( $self, $field ) = @_;
     if( $self->something ) {
        return '<p>This type of explanation...</p>';
     }
     else {
        return '<p>Another type of explanation...</p>';
     }
  }
  #----
  has_field 'username' => ( type => 'Display' );
  sub html_username {
      my ( $self, $field ) = @_;
      return '<div><b>User:&nbsp;</b>' . $field->value . '</div>';
  }
  

or set the name of the rendering method:

   has_field 'explanation' => ( type => 'Display', set_html => 'my_explanation' );
   sub my_explanation {
     ....
   }

You can also supply an 'html' method with a trait or a custom field. See examples
in t/field_traits.t and t/xt/display.t of the distribution.

=cut

has 'html' => ( is => 'rw', isa => 'Str', builder => 'build_html' ); 
sub build_html {''}
has 'set_html' => ( isa => 'Str', is => 'ro');
sub _set_html_meth {
    my $self = shift;
    return $self->set_html if $self->set_html;
    my $name = $self->full_name;
    $name =~ s/\./_/g;
    $name =~ s/_\d+_/_/g;
    return 'html_' . $name;
}
sub _can_form_html {
    my $self = shift;
    my $set_html = $self->_set_html_meth;
    return
        unless $self->form &&
            $set_html &&
            $self->form->can( $set_html );
    return $set_html;
}
sub _form_html {
    my $self = shift;
    return unless (my $meth = $self->_can_form_html);
    if( $self->form->meta->has_attribute( $meth ) ) {
        return $self->form->$meth;
    }
    else {
        return $self->form->$meth($self);
    }
}

sub render {
    my $self = shift;
    if ( my $meth = $self->_can_form_html ) {
        return $self->form->$meth( $self );
    }
    elsif ( $self->html ) {
        return $self->html;
    }
    return '';
}

sub _result_from_object {
    my ( $self, $result, $value ) = @_;
    $self->_set_result($result);
    $self->value($value);
    $result->_set_field_def($self);
    return $result;
}

after 'clear_data' => sub {
    my $self = shift;
    $self->clear_value;
};

__PACKAGE__->meta->make_immutable;
1;
