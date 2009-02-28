package BookDB::Form::BorrowerX;

use Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'HTML::FormHandler::Render::Simple';


=head1 NAME

Form object for Borrower 

=head1 DESCRIPTION

Catalyst Controller.

=cut


has '+item_class' => ( default => 'Borrower' );

__PACKAGE__->meta->make_immutable;

sub field_list {
	return {
		fields => {
			name         => {
                type => 'Text',
                required => 1,
                order    => 1,
                label    => "Name",
                unique   => 1,
                unique_message => 'That name is already in our user directory',
            },
			email        => {
                type => 'Email',
                required => 1,
                order => 4,
                label => "Email",
            },
			phone        => {
                type => 'Text',
                order => 2,
                label => "Telephone",
            },
			url          => {
                type => 'Text',
                order => 3,
                label => 'URL',
            },
         books => 'Text',
		},
      unique => {
         name => 'That name is already in our user directory'
      },
	};
}


=head1 AUTHOR

Gerda Shank

=head1 LICENSE AND COPYRIGHT

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut

1;
