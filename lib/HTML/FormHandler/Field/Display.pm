package HTML::FormHandler::Field::Display;
# ABSTRACT: display only field
use strict;
use warnings;

use Moose;
extends 'HTML::FormHandler::Field::NoValue';
use namespace::autoclean;

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

or provide a 'render_method':

   has_field 'my_button' => ( type => 'Display', render_method => \&render_my_button );
   sub render_my_button {
       my $self = shift;
       ....
       return '...';
   }

=cut

has 'html' => ( is => 'rw', isa => 'Str', builder => 'build_html', lazy => 1 );
sub build_html {''}
has 'set_html' => ( isa => 'Str', is => 'ro');
has '+do_label' => ( default => 0 );

has 'render_method' => (
    traits => ['Code'],
    is     => 'ro',
    isa    => 'CodeRef',
    lazy   => 1,
    predicate => 'does_render_method',
    handles => { 'render' => 'execute_method' },
    builder => 'build_render_method',
);

sub build_render_method {
    my $self = shift;

    my $set_html = $self->set_html;
    $set_html ||= "html_" . HTML::FormHandler::Field::convert_full_name($self->full_name);
    return sub { my $self = shift; $self->form->$set_html($self); }
        if ( $self->form && $self->form->can($set_html) );
    return sub {
        my $self = shift;
        return $self->html;
    };
}

sub _result_from_object {
    my ( $self, $result, $value ) = @_;
    $self->_set_result($result);
    $self->value($value);
    $result->_set_field_def($self);
    return $result;
}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
