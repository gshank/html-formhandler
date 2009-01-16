package BookDB::View::TT;

use strict;
use base 'Catalyst::View::TT';

=head1 NAME

BookDB::V::TT - TT View Component

=head1 SYNOPSIS

See L<BookDB>

=head1 DESCRIPTION

TT View Component.

=cut

BookDB::View::TT->config({
    TEMPLATE_EXTENSION => '.tt',
    INCLUDE => [ BookDB->path_to('root') ],
});


=head1 AUTHOR

Gerda Shank

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
