package HTML::FormHandler::Field::HtmlArea;

use Moose;
extends 'HTML::FormHandler::Field::TextArea';
use HTML::Tidy;
use File::Temp;
our $VERSION = '0.01';

my $tidy;

has '+widget' => ( default => 'textarea' );

sub validate {
    my $field = shift;

    return unless $field->next::method;

    $tidy ||= $field->tidy;
    $tidy->clear_messages;

    # parse doesn't pass the config file in HTML::Tidy.
    $tidy->clean( $field->input );

    my $ok = 1;

    for ( $tidy->messages ) {
        $field->add_error( $_->as_string );
        $ok = 0;
    }

    return $ok;
}

# Parses config file.  Do it once.

my $tidy_config;

sub tidy {
    my $field = shift;
    $tidy_config ||= $field->init_tidy;
    my $t = HTML::Tidy->new( { config_file => $tidy_config } );

    $t->ignore( text => qr/DOCTYPE/ );
    $t->ignore( text => qr/missing 'title'/ );
    # $t->ignore( type => TIDY_WARNING );

    return $t;
}

sub init_tidy {

    my $tidy_conf = <<EOF;
char-encoding: utf8
input-encoding: utf8
output-xhtml: yes
logical-emphasis: yes
quiet: yes
show-body-only: yes
wrap: 45
EOF

    my $tidy_file = File::Temp->new( UNLINK => 1 );
    print $tidy_file $tidy_conf;
    close $tidy_file;

    return $tidy_file;

}

=head1 NAME

HTML::FormHandler::Field::HtmlArea - Input HTML in a textarea

=head1 SYNOPSIS

See L<HTML::FormHandler>

=head1 DESCRIPTION

Field validates using HTML::Tidy.  A simple Tidy configuration file
is created and written to disk each time the field is validated.
Widget type is 'textarea'.

=head1 DEPENDENCIES

L<HTML::Tidy>  L<File::Temp>

=head1 AUTHORS

Gerda Shank

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
