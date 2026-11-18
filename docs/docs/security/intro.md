---
sidebar_position: 2
---

# Intro

Security within MijnBureau is a collaborative effort involving multiple stakeholders, with primary responsibility shared between the `Service Integrator` and the MijnBureau suite.

In this section, we outline the specific responsibilities of each party and describe best practices for building and maintaining a secure system.

## Admin interfaces

The Django admin interfaces of the applications (`/admin/`) are not exposed on public
routes. Django admin authenticates against local Django superusers only (OIDC users have
no usable password), so it is treated as break-glass access and reached through a
`kubectl port-forward` to the application's backend service:

```bash
kubectl -n mijnbureau-drive port-forward svc/drive-backend 8080:80
# then open http://localhost:8080/admin/
```

Superusers should be created per application only when needed (`kubectl exec ... --
python manage.py createsuperuser`) and removed again afterwards.
