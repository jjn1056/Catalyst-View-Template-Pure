# TITLE

Catalyst::View::Template::Pure - Catalyst view adaptor for Template::Pure

# SYNOPSIS

    package  MyApp::View::Story;

    use Moose;
    use DateTime;
    use HTTP::Status qw(:constants);

    extends 'Catalyst::View::Template::Pure';

    has [qw/title body/] => (is=>'ro', required=>1);

    sub timestamp { DateTime->now }

    __PACKAGE__->config(
      allows_status => [HTTP_OK],
      init_time => scalar(localtime),
      template => q[
        <!doctype html>
        <html lang="en">
          <head>
            <title>Title Goes Here</title>
          </head>
          <body>
            <div id="main">Content goes here!</div>
            <div id="timestamp">Server Started on:</div>
          </body>
        </html>      
      ],
      directives => [
        'title' => 'title',
        '#main' => 'body',
        '#timestamp+' => 'timestamp',
      ],
    );

    __PACKAGE__->meta->make_immutable

Create a controller that uses this view:

    package MyApp::Controller::Story;

    use Moose;
    use MooseX::MethodAttributes;

    extends 'Catalyst::Controller';

    sub display_story :Local Args(0) {
      my ($self, $c) = @_;
      $c->view('Story',
        title => 'A Dark and Stormy Night...',
        body => 'It was a dark and stormy night. Suddenly...',
      )->http_ok;
    }

    __PACKAGE__->meta->make_immutable

When hitting a page that activates the 'display\_story' action, returns:

      <!doctype html>
      <html lang="en">
        <head>
          <title>A Dark and Stormy Night...</title>
        </head>
        <body>
          <div id="main">It was a dark and stormy night. Suddenly...</div>
          <div id="timestamp">Server Started on: July 29, 2016 11:30:00</div>
        </body>
      </html>

# DESCRIPTION

[Catalyst::View::Template::Pure](https://metacpan.org/pod/Catalyst::View::Template::Pure) is an adaptor for [Template::Pure](https://metacpan.org/pod/Template::Pure) for the [Catalyst](https://metacpan.org/pod/Catalyst)
web development framework.  [Template::Pure](https://metacpan.org/pod/Template::Pure) is an HTML templating system that fully
separates concerns between markup (the HTML), transformations on that markup (called
'directives') and data that the directives use on the template to return a document.

I highly recommend you review the documentation for [Template::Pure](https://metacpan.org/pod/Template::Pure) if you wish to gain a
deeper understanding of how this all works.  The following information is specific to how
we adapt [Template::Pure](https://metacpan.org/pod/Template::Pure) to run under [Catalyst](https://metacpan.org/pod/Catalyst); as a result it will assume you already
know the basics of creating templates and directives using [Template::Pure](https://metacpan.org/pod/Template::Pure)

# CREATING AND USING VIEWS

In many template adaptors for [Catalyst](https://metacpan.org/pod/Catalyst) you create a single 'View' which is a sort of
factory that processes a whole bunch of templates (typically files in a directory under
$APPHOME/root).  Variables are passed to the view view the Catalyst stash.  Choosing the
template to process is typically via some convention based on the action path and/or via
a special stash key.

This system works fine to a point, but I've often found when a system gets complex (think
dozens of controllers and possible hundreds of templates) it gets messy.  Because the
stash is not strongly typed you have no declared interface between the view and your
controller.  This can be great for rapid development but a long term maintainance nightmare.
People often lose track of what is and isnt' in the stash for a given template (not to
mention the fact that a small typo will 'break' the interface between the stash and the
view template.

[Catalyst::View::Template::Pure](https://metacpan.org/pod/Catalyst::View::Template::Pure) is a bit different.  Instead of a single template
factory view, you need to make a view subclass per resource (that is, for each HTML
webpage you want to display).  Additionally you will make a view for any of the
reusable bits that often make up a complex website, such as includes and master page
layouts.  That sounds like a lot of views, and will seem wierd to you at first if you
are used to the old style 'one view class to rule the all'.  The requirement to make a
new View subclass for each page or part of a page does add a bit of overhead to the
development process.  The upside is that you are creating strongly types views that
can contain their own logic, defaults and anything else that can go into a Perl class.
This way you can enforce an interface between your views and the controllers that use
them.  Over time the extra, original overhead should pay you back in less maintainance
issues and in greating code clarity.  Lets create a simple view:

    package  MyApp::View::Hello;

    use Moose;
    use HTTP::Status qw(:constants);

    extends 'Catalyst::View::Template::Pure';

    has [qw/title name/] => (is=>'ro', required=>1);

    sub timestamp { scalar localtime }

    __PACKAGE__->config(
      template => q[
        <html>
          <head>
            <title>Title Goes Here</title>
          </head>
          <body>
            <p>Hello <span id='name'>NAME</span>!<p>
            <p>This page was generated on: </p>
          </body>
        </html>      
      ],
      directives => [
        'title' => 'title',
        '#name' => 'name',
        '#timestamp+' => 'timestamp',
      ],
      allows_status => [HTTP_OK],
    );

    __PACKAGE__->meta->make_immutable;

So this is a very simple view with just three bits of data that is used to create
an end result webpage.  Two fields need to be passed to the view (title and name)
while the third one (timestamp) is generated locally by the view itself.  The three
entries under the 'directives' key are instructions to [Template::Pure](https://metacpan.org/pod/Template::Pure) to run
an action at a particular CSS match in the templates HTML DOM (see documentation
for [Template::Pure](https://metacpan.org/pod/Template::Pure) for more details). Lets use this in a controller:

    package MyApp::Controller::Hello;

    use Moose;
    use MooseX::MethodAttributes;

    extends 'Catalyst::Controller';

    sub say_hello :Path('') Args(0) {
      my ($self, $c) = @_;
      $c->view('Hello',
        title => 'Hello to You!',
        name => 'John Napiorkowski',
      )->http_ok;
    }

    __PACKAGE__->meta->make_immutable;

Again, if you are following a classic pattern in [Catalyst](https://metacpan.org/pod/Catalyst) you might be using the
[Catalyst::Action::RenderView](https://metacpan.org/pod/Catalyst::Action::RenderView) on a global 'end' action (typically in your
Root controller) to do the job of forwarding the request to a view.  Then, the view
would decide on a template based on a few factors, such as the calling action's
private name.  In this case instead we are calling the view directly, as well as
directly sending the view's arguments call to the view, instead of via the
stash (although as we will see later, you can still use the stash and even the
[Catalyst::Action::RenderView](https://metacpan.org/pod/Catalyst::Action::RenderView) approach if that is really the best setup for
your application).

**NOTE** An important distinction here to remember is that when you pass arguments to
the view, those arguments are not passed directly as data to the underlying
[Template::Pure](https://metacpan.org/pod/Template::Pure) object.  Rather these arguments are combined with any local or global
configuration and used as arguments when calling ->new on the actual view component.
So arguments passed, even via the stash, as not directly exposed to the template, but
rather mediated via the actual view object. Only attributes and methods on the view
object are exposed to the template.

In calling the view this way you setup a stronger association between your controller
and the view.  This can add a lot of clarity to your code when you have very large
and complex websites.  In addition the view returned is scoped 'Per Request', instead
of 'Per Application' like most common Catalyst views in use.  'Per Request' in this
case means that the first time you call for the view in a given request, we create
a new instance of that view from the arguments passed.  Subsequent calls to the same
view will return the same instance created earlier.  This can be very useful if you
have complex chained actions and wish to add information to a view over the course
of a number of actions in the chain.  However when the response is finalized and
returned to the client, the current request goes out of scope which triggers DESTROY
on the view.

Another useful thing about the fact that the view is scoped 'Per Request' is that
it contains a reference to the context.  So in your custom view methods you can call
$self->ctx and get the context to do stuff like build links or even access models.
Just keep in mind you need to think carefully about what logic is proper to the
view and which is proper to the controller.  In general if there is logic that
would be the same if the resource generated by the view was a different type (say
JSON or XML) then its likely that logic belongs in the controller.  However I
encourage you to choose the approach that leads to clean and reusable code.

Lastly, [Catalyst::View::Template::Pure](https://metacpan.org/pod/Catalyst::View::Template::Pure) allows you to specify the type of response
status code can be associated with this view.  This can be useful when you want
to make it clear that a given view is an error response or for created resources.
To enable this feature you simple set the 'allows\_status' configuration key to
an arrayref of the HTTP status codes allowed.  This is simple a number (201 for
created, for example) but for clarity in the given example I've used [HTTP::Status](https://metacpan.org/pod/HTTP::Status)
to give the allowed codes a friendly name.  You can choose to follow this example
or not!  As a futher timesaver, when you set allowed statuses, we will inject into
your view some helper methods to set the desired status.  As in the given example:

    $c->view('Hello',
      title => 'Hello to You!',
      name => 'John Napiorkowski',
    )->http_ok;

We are setting $c->res->status(200).  For people that prefer the actual code numbers
there is also ->http\_200 injected if you are better with the number codes instead of
the friendly names but I recommend you choose one or the other approach for your project!

Please keep in mind that calling ->http\_ok (or any of the helper methods) does not
immediately finalize your response.  If you want to immediately finalize the
response (say for example you are returning an error and want to stop processing the
remaining actions) you will need to $c->detach like normal.  To make this a little
easier you can chain off the response helper like so:

    $c->view('NotFound')
      ->http_404
      ->detach;

Sending a request that hits the 'say\_hello' action would result in:

    <html>
      <head>
        <title>Hello to You!</title>
      </head>
      <body>
        <p>Hello <span id='name'>John Napiorkowski</span>!<p>
        <p>This page was generated on: Tue Aug  2 09:17:48 2016</p>
      </body>
    </html>  

(Of course the timestamp will vary based on when you run the code, this
was the result I got only at the time of writing this document).

# USING THE STASH

If you are used to using the [Catalyst](https://metacpan.org/pod/Catalyst) stash to pass information to your view
or you have complex chaining and like to build up data over many actions, you
may continue to do that.  For example:

    sub say_hello :Path('') Args(0) {
      my ($self, $c) = @_;
      $c->stash(
        title => 'Hello to You!',
        name => 'John Napiorkowski',
      );
      $c->view('Hello')->http_ok;
    }

Would be the functional equal to the earlier example.  However as noted those
arguments are not passed directly to the template as data, but rather passed as
initialization arguments to the ->new method when calling the view the first time
in a request.  So you may still use the stash, but because the view is mediating
the stash data I believe we mitigate some of the stash's downsides (such as a lack
of strong typing, missing defined interface and issues with typos, for example).

# CHAINING TEMPLATE TRANFORMATIONS

There are several ways to decompose your repeated or options template transforms
into reusable chunks, at the View level.  However there are often cases when the
decision to use or apply changes to your template best occur at the controller
level.  For example you may wish to add some messaging to your template if a form
has incorrect data.  In those cases you may apply additional Views.  Applied views
will use as its starting template the results of the previous.  For example:

    sub say_hello :Path('') Args(0) {
      my ($self, $c) = @_;
      $c->stash(
        title => 'Hello to You!',
        name => 'John Napiorkowski',
      );
      $c->view('Hello')->http_ok;
    }

    sub process_form :POST Path('') Args(0) {
      my ($self, $c) = @_;
      my $v = $c->view('Login');

      if($c->model('Form')->is_valid) {
        $v->http_ok;
      } else {
        $v->apply('IncorrectLogin')
          ->http_bad_request
          ->detach;
      }
    }

You may chain as many applied views as you like, even using this technique to build up
an entire page of results.

# MAPPING TEMPLATE ARGS FROM AN OBJECT

Generally you send arguments to the View via the stash or via arguments on the view
call itself.  This might sometimes lead to highly verbose calls:

    sub user :Path Args(1) {
      my ($self, $c, $id) = @_:
      my $user = $c->model('Schema::User')->find($id) ||
        $c->view('NoUser')->http_bad_request->detach;

      $c->view('UserProfile',
        name => $user->name,
        age => $user->age,
        location => $user->location,
        ...,
      );
    }

Listing each argument has the advantage of clarity but the verbosity can be distracting
and take programmer time.  So, in the case where a source object provides an interface
which is identical to the interface required by the view, you may just pass the object
and we will map required attributes for the view from method named on the object.  For
example:

    sub user :Path Args(1) {
      my ($self, $c, $id) = @_:
      my $user = $c->model('Schema::User')->find($id) ||
        $c->view('NoUser')->http_bad_request
          ->detach;

      $c->view(UserProfile => $user)
        ->http_ok;
    }

It is up to you to decide if this is creating too much structual binding between your
view and its model.  You may or may not find it a useful convention.

# COMMON VIEW TASKS

The following are suggestions regarding some of the more common tasks we need to
use a view for.  Most of this is covered in [Template::Pure](https://metacpan.org/pod/Template::Pure) in greater detail,
but I wanted to show the minor 'twists' the Catalyst adaptor presents.  Please
keep in mind the following are not the only ways to solve this problems, but just
what I think of as very straightfoward ways that are a good starting point for you
as you climb the learning curve with [Template::Pure](https://metacpan.org/pod/Template::Pure)

# METHODS

This class defines the following methods.

## RUNTIME HOOKS

This class defines the following method hooks you may optionally defined in your
view subclass in order to control or otherwise influence how the view works.

# CONFIGURATION

This Catalyst Component supports the following configuation

## template

## template\_src

## auto\_template\_src

# ALSO SEE

[Catalyst](https://metacpan.org/pod/Catalyst), [Template::Pure](https://metacpan.org/pod/Template::Pure).

[Template::Pure](https://metacpan.org/pod/Template::Pure) is based on a client side Javascript templating system, 'pure.js'.  See
[https://beebole.com/pure/](https://beebole.com/pure/) for more information.

# AUTHORS & COPYRIGHT

John Napiorkowski [email:jjnapiork@cpan.org](email:jjnapiork@cpan.org)

# LICENSE

Copyright 2016, John Napiorkowski  [email:jjnapiork@cpan.org](email:jjnapiork@cpan.org)

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.