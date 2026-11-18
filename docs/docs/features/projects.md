# Projects

MijnBureau includes **Projects**, the collaborative project management application from
LaSuite. Teams plan work with projects, tasks, assignees, due dates, priorities and
reminders, without leaving the workspace.

![Projects preview](/img/features/task.png)

## What you can do

- Create projects with task lists and assign work to team members.
- Set start and due dates, priorities, progress and reminders.
- Group tasks with categories and filters.
- Comment on tasks and follow changes.

## Configuration

Projects is enabled with `application.projects.enabled`. It authenticates through
Keycloak and stores its data in PostgreSQL. The environment values support a theme override
for branding in `application.projects.theme`.

Projects is currently marked **beta** in the Bureaublad.

- [OIDC client configuration](../components/keycloak.md)
- [PostgreSQL](../datastores/postgresql.md)
