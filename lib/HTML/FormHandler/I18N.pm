package HTML::FormHandler::I18N;
# ABSTRACT: internationalization

use strict;
use warnings;
use base ('Locale::Maketext');
use Try::Tiny;

sub maketext {
    my ( $lh, @message ) = @_;
    return '' unless scalar @message;
    return '' unless defined $message[0];
    my $out;
    try {
        $out = $lh->SUPER::maketext(@message);
    }
    catch {
        die "Unable to do maketext on: " . $message[0];
    };
    return $out;
}

1;

