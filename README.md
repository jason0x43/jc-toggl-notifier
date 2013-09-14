Toggl menu bar notifier
=======================

<p align="center">
<img alt="Screenshot" src="https://dl.dropboxusercontent.com/s/sv3loafccs3iyoc/jc-toggl_notifier_screenshot.png" />
</p>

Alfred is great for interacting with Toggl, but I kept forgetting to stop my
timers. This notifier sits in the menu bar and checks Toggl every 3 minutes to
see if you have an active timer. If you do, it turns red; otherwise it's black.
The notifier also responds to notifications from the workflow, so if you start
or stop a timer via the workflow the timer will change colors immediately.

When a timer is active, clicking on the notifier will show the timer's
description, and the time entry will show up with a highlighted icon in the
Alfred listing. Clicking on the timer's description in the notifier menu will
stop the timer.

The notifier requires my [Alfred workflow][workflow] to function. It needs an
API key, and the workflow is where it gets it from. Well, *requires* might be a
bit strong; you could write an AppleScript to send your key to to the notifier
(that's how my workflow does it).

Requirements
------------

* A Toggl account
* My Toggl [Alfred workflow][workflow]. The workflow package includes a
  compiled version of this workflow.

Credits
-------

All hail [Toggl][toggl] for building a great time tracking system. Also,
I used the icon from the Toggl desktop app to make the icon for this notifier.

[pkg]: https://dl.dropboxusercontent.com/s/ff7hsrn1og72xey/jc-toggl.alfredworkflow
[alfred]: http://www.alfredapp.com
[toggl]: http://www.toggl.com
[workflow]: https://github.com/jason0x43/jc-toggl
