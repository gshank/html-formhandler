<html>
  <head><title>Howdy [% name %]</title></head>
  <body>
    <p>My favourite things, [% interest %]!</p>
    <ul>
      [% SECTION items %]
        <li>[% item %]</li>
      [% END %]
    </ul>

    [% SECTION possible_geek %]
        <span>I likes DnD...</span>
    [% END %]
  </body>
</html>

