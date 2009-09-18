package BookDB::Form::Upload;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has '+enctype' => ( default => 'multipart/form-data');

has_field 'file' => ( type => 'Upload' );
has_field 'submit' => ( type => 'Submit', value => 'Upload' );

1;
