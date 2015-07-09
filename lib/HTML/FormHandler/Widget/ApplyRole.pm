package HTML::FormHandler::Widget::ApplyRole;
# ABSTRACT: role to apply widgets
use strict;
use warnings;

use Moose::Role;
use File::Spec;
use Class::MOP;
use Try::Tiny;
use Class::Load qw/ load_optional_class /;
use namespace::autoclean;

our $ERROR;

sub apply_widget_role {
    my ( $self, $target, $widget_name, $dir ) = @_;

    my $render_role = $self->get_widget_role( $widget_name, $dir );
    $render_role->meta->apply($target) if $render_role;
}

sub get_widget_role {
    my ( $self, $widget_name, $dir ) = @_;
    my $widget_class      = $self->widget_class($widget_name);
    my $ldir              = $dir ? '::' . $dir . '::' : '::';

    my $widget_ns = $self->widget_name_space;
    my @name_spaces = @$widget_ns;
    push @name_spaces, ('HTML::FormHandler::Widget', 'HTML::FormHandlerX::Widget');
    my @classes;
    if ( $widget_class =~ s/^\+// )
    {
        push @classes, $widget_class;
    }
    foreach my $ns (@name_spaces) {
        push @classes,  $ns . $ldir . $widget_class;
    }
    foreach my $try (@classes) {
        return $try if load_optional_class($try);
    }
    die "Can't find $dir widget $widget_class from " . join(", ", @name_spaces);
}

# this is for compatibility with widget names like 'radio_group'
# RadioGroup, Textarea, etc. also work
sub widget_class {
    my ( $self, $widget ) = @_;
    return unless $widget;
    if($widget eq lc $widget) {
        $widget =~ s/^(\w{1})/\u$1/g;
        $widget =~ s/_(\w{1})/\u$1/g;
    }
    return $widget;
}

use namespace::autoclean;
1;
