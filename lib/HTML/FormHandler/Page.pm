package HTML::FormHandler::Page;

use Moose;
with 'HTML::FormHandler::Pages';

has 'fields' => (
    traits     => ['Array'],
    isa        => 'ArrayRef[Str]',
    is         => 'rw',
    default    => sub { [] },
    handles   => {
        all_fields => 'elements',
        clear_fields => 'clear',
        push_field => 'push',
        num_fields => 'count',
        has_fields => 'count',
    }
);


1;
