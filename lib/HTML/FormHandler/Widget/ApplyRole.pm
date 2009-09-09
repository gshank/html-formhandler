package HTML::FormHandler::Widget::ApplyRole;

use Moose::Role;
use File::Spec;
use Class::Load ('try_load_class' );

our $ERROR;

sub apply_widget_role {
    my ( $self, $target, $widget_name, $dir ) = @_;

    my $widget_name_space = $self->widget_name_space;
    my $widget_class      = $self->widget_class($widget_name);
    my $ldir              = $dir ? '::' . $dir . '::' : '::';
    my @name_spaces;
    push @name_spaces, ref $widget_name_space ? @{$widget_name_space} : $widget_name_space
        if $widget_name_space;
    push @name_spaces, 'HTML::FormHandler::Widget';
    my $meta;
    my $found;

    foreach my $ns (@name_spaces) {
        my $render_role = $ns . $ldir . $self->widget_class($widget_name);
        if ( try_load_class($render_role) ) {
            $target->meta->make_mutable;
            $render_role->meta->apply($target);
            $target->meta->make_immutable;
            $found++;
            last;
        }
    }
    die "$dir widget $widget_class not found in " . join ", ", @name_spaces unless $found;
}

# this is for compatibility with widget names like 'radio_group'
# RadioGroup, Textarea, etc. also work
sub widget_class {
    my ( $self, $widget ) = @_;
    return unless $widget;
    $widget =~ s/^(\w{1})/\u$1/g;
    $widget =~ s/_(\w{1})/\u$1/g;
    return $widget;
}

use namespace::autoclean;
1;
