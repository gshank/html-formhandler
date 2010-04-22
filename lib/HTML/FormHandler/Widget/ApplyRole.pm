package HTML::FormHandler::Widget::ApplyRole;

use Moose::Role;
use File::Spec;
use Class::MOP;
use Try::Tiny;

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
    my @name_spaces = ( @{$self->widget_name_space}, 
        ('HTML::FormHandler::Widget', 'HTML::FormHandlerX::Widget') );
    foreach my $ns (@name_spaces) {
        my $render_role = $ns . $ldir . $widget_class;
        try { Class::MOP::load_class($render_role) } catch { die $_ unless $_ =~ /^Can't locate/; };
        return $render_role if Class::MOP::is_class_loaded($render_role);
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
