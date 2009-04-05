package BookDB::Form::Borrower;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'HTML::FormHandler::Render::Simple';


=head1 NAME

Form object for Borrower 

=head1 DESCRIPTION

Catalyst Controller.

=cut


has '+item_class' => ( default => 'Borrower' );

__PACKAGE__->meta->make_immutable;

has_field 'name' => (
                type => 'Text',
                required => 1,
                order    => 1,
                label    => "Name",
                unique   => 1,
                unique_message => 'That name is already in our user directory',
);
has_field 'email'      => (
                type => 'Email',
                required => 1,
                order => 4,
                label => "Email",
            );
has_field 'phone' => (
                type => 'Text',
                order => 2,
                label => "Telephone",
            );
has_field 'url' => (
                type => 'Text',
                order => 3,
                label => 'URL',
            );
has_field 'active' => ( type => 'Boolean', label => "Active?" );


=head1 AUTHOR

Gerda Shank

=head1 LICENSE AND COPYRIGHT

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut

__PACKAGE__->meta->make_immutable;
no HTML::FormHandler::Moose;
1;
