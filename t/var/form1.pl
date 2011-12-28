{
    action => '/login',
    field_list => [
        { type => 'Text',
          name => 'user',
          label => 'Username',
          required => 1,
        },
        { type => 'Password',
          name => 'pass',
          label => 'Password',
          required => 1,
        },
        { type => 'Submit',
          name => 'submit',
          value => 'Login',
        },
    ],
}
