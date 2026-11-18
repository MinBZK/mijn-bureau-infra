# Calendar

MijnBureau includes **Calendars**, the scheduling application from LaSuite. Users plan
events, invite participants, attach meeting links and subscribe to shared calendars, all
inside the same single sign-on session as the rest of the suite.

Events created in Calendars can include a video conference link, so a meeting in the
calendar opens directly in Meet. Calendars also exposes CalDAV, which lets desktop and
mobile clients synchronise through the same hostname as the web application.

![Calendar preview](/img/features/agenda.png)

## What you can do

- Personal and shared calendars with week, month and agenda views.
- Invite participants and attach a video conference to an event.
- Synchronise with CalDAV clients such as Thunderbird, Apple Calendar and DAVx5.
- Import and export calendar data.

## Configuration

Calendars is enabled with `application.calendars.enabled`. The component documentation
lists every setting, including the CalDAV service and OIDC client:

- [Calendars component documentation](../components/calendars.md)
- [Identity provider](../components/keycloak.md)
