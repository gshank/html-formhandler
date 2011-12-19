package HTML::FormHandler::Render::Util;

use Sub::Exporter;
Sub::Exporter::setup_exporter({ exports => [ 'process_attrs' ] } );

# this is a function for processing various attribute flavors
sub process_attrs {
    my ($attrs) = @_;

    my @use_attrs;
    for my $attr( sort keys %$attrs ) {
        my $value = '';
        if( defined $attrs->{$attr} ) {
            if( ref $attrs->{$attr} eq 'ARRAY' ) {
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
    return $output;
}


1;
