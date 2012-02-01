package HTML::FormHandler::Render::Util;
# ABSTRACT: rendering utility
use Sub::Exporter;
Sub::Exporter::setup_exporter({ exports => [ 'process_attrs', 'cc_widget', 'ucc_widget' ] } );

=head1 SYNOPSIS

The 'process_attrs' takes a hashref and creates an attribute string
for constructing HTML.

    my $attrs => {
        some_attr => 1,
        placeholder => 'Enter email...",
        class => ['help', 'special'],
    };
    my $string = process_attrs($attrs);

...will produce:

    ' some_attr="1" placeholder="Enter email..." class="help special"'

If an arrayref is empty, it will be skipped. For a hash key of 'javascript'
only the value will be appended (without '$key=""');

=cut

# this is a function for processing various attribute flavors
sub process_attrs {
    my ($attrs) = @_;

    my @use_attrs;
    my $javascript = delete $attrs->{javascript} || '';
    for my $attr( sort keys %$attrs ) {
        my $value = '';
        if( defined $attrs->{$attr} ) {
            if( ref $attrs->{$attr} eq 'ARRAY' ) {
                # we don't want class="" if no classes specified
                next unless scalar @{$attrs->{$attr}};
                $value = join (' ', @{$attrs->{$attr}} );
            }
            else {
                $value = $attrs->{$attr};
            }
        }
        push @use_attrs, sprintf( '%s="%s"', $attr, $value );
    }
    my $output = join( ' ', @use_attrs );
    $output = " $output" if length $output;
    $output .= " $javascript" if $javascript;
    return $output;
}

sub cc_widget {
    my $widget = shift;
    return '' unless $widget;
    if($widget eq lc $widget) {
        $widget =~ s/^(\w{1})/\u$1/g;
        $widget =~ s/_(\w{1})/\u$1/g;
    }
    return $widget;
}

sub ucc_widget {
    my $widget = shift;
    if($widget ne lc $widget) {
        $widget =~ s/::/_/g;
        $widget =~ s/[a-z]\K([A-Z][a-z])/_\L$1/g;
        $widget = lc($widget);
    }
    return $widget;
}


1;
