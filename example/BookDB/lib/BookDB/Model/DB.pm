package BookDB::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'BookDB::Schema::DB',
    connect_info => [
        'dbi:SQLite:db/book.db',
        
    ],
);

=head1 NAME

BookDB::Model::DB - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<BookDB>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<BookDB::Schema::DB>

=head1 AUTHOR

Gerda Shank

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
