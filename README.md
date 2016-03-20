# HTML::FormHandler - HTML forms using Moose


See the manual at [HTML::FormHandler::Manual]( https://metacpan.org/pod/HTML::FormHandler::Manual).

HTML::FormHandler maintains a clean separation between form construction and form rendering. It allows you to define your forms and fields in a number of flexible ways. Although it provides renderers for HTML, you can define custom renderers for any kind of presentation.

HTML::FormHandler allows you to define form fields and validators. It can be used for both database and non-database forms, and will automatically update or create rows in a database. It can be used to process structured data that doesn't come from an HTML form.

One of its goals is to keep the controller/application program interface as simple as possible, and to minimize the duplication of code. In most cases, interfacing your controller to your form is only a few lines of code.


The typical application for FormHandler would be in a Catalyst, DBIx::Class, Template Toolkit web application, but use is not limited to that. FormHandler can be used in any Perl application.

# QUICK START GUIDE:

This git repository can build a HTML::FormHandler distribution using [dzil]( https://metacpan.org/pod/distribution/Dist-Zilla/bin/dzil) command 
from the [Dist::Zilla]( https://metacpan.org/pod/Dist::Zilla) distribution that you could install using cpan.

Once you have [Dist::Zilla]( https://metacpan.org/pod/Dist::Zilla) installed this distribution can be build or installed using [dzil]( https://metacpan.org/pod/distribution/Dist-Zilla/bin/dzil):

     dzil build   # Generates a build directory and the targz of the  HTML::FormHandler distribution
     dzil install # Installs the distribution.


