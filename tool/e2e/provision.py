# SPDX-License-Identifier: AGPL-3.0-only
"""Prepare a Housecairn server for the e2e test of the third way (docs/plan.md, lot 4b).

Run inside the server's container, by its own Django shell:

    docker exec -i <container> python -m housecairn.entrypoint manage shell < tool/e2e/provision.py

It makes an account with two homes, a session of that account (the browser of the
sign-in, already signed in, so that the test drives the real consent page and OAuth
flow), and an API token of scope read and write on both homes, through which the test
reads and writes "on the web". It prints one line, `E2E {json}`, which the CI job turns
into environment variables. Nothing here is a secret outside the throwaway container.
"""

import json

from django.contrib.auth import BACKEND_SESSION_KEY, HASH_SESSION_KEY, SESSION_KEY, get_user_model
from django.contrib.sessions.backends.db import SessionStore

from housecairn.apitokens import services as token_services
from housecairn.homes import services as home_services

User = get_user_model()
user = User.objects.create_user(
    username="e2e", email="e2e@example.com", password="e2e-password-not-secret"
)
first = home_services.create_home(user, name="E2E house")
second = home_services.create_home(user, name="E2E flat")

session = SessionStore()
session[SESSION_KEY] = str(user.pk)
session[BACKEND_SESSION_KEY] = "django.contrib.auth.backends.ModelBackend"
session[HASH_SESSION_KEY] = user.get_session_auth_hash()
session.create()

_, api_token = token_services.create_token(
    user,
    name="e2e",
    scopes=["read", "write"],
    homes=[first, second],
    lifetime_days=30,
)

print(
    "E2E "
    + json.dumps(
        {
            "HC_E2E_SESSION": session.session_key,
            "HC_E2E_API_TOKEN": api_token,
            "HC_E2E_HOME": str(first.id),
            "HC_E2E_HOME_2": str(second.id),
        }
    )
)
