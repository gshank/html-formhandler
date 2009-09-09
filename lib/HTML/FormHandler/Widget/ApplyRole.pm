package HTML::FormHandler::Widget::ApplyRole;

use Moose::Role;
use File::Spec;
use Class::Load ('try_load_class' );

our $ERROR;

sub apply_widget_role {
    my ( $self, $target, $widget_name, $dir ) = @_;

    my $widget_class      = $self->widget_class($widget_name);
    my $ldir              = $dir ? '::' . $dir . '::' : '::';
    my @name_spaces = ( @{$self->widget_name_space}, 'HTML::FormHandler::Widget' );
    my $found;
    foreach my $ns (@name_spaces) {
        my $render_role = $ns . $ldir . $widget_class;
        if ( try_load_class($render_role) ) {
            $render_role->meta->apply($target);
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
