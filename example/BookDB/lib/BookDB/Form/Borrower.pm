package BookDB::Form::Borrower;

use Moose;
extends 'HTML::FormHandler::Model::DBIC';


=head1 NAME

Form object for Borrower 

=head1 DESCRIPTION

Catalyst Controller.

=cut


has '+item_class' => ( default => 'Borrower' );
has '+name_prefix' => ( default => 'borrower' );

sub profile {
	return {
		fields => {
			name         => {
                type => 'Text',
                required => 1,
                order    => 1,
                label    => "Name",
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
                type => 'URL',
                order => 3,
                label => 'URL',
            },
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
