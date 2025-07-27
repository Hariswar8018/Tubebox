import { defineStorage } from "@aws-amplify/backend";

export const storage = defineStorage({
  name: "gallery",
  access: (allow) => ({
    "media/public/{entity_id}/*": [
      allow.guest.to(["read"]),

      // This is NOT enough to grant access to the authenticated user, if the user belongs to a group
      // You must grant access to the group for this to be effective
      allow.entity("identity").to(["read", "write", "delete"]),

      // this works. But my test user belonged to the "Users" group, which was not included here.
      allow.groups(["Admins", "Staff", "SystemAdmins"]).to(["read", "write", "delete"]),
    ],
    "media/protected/{entity_id}/*": [
      allow.authenticated.to(["read"]),         //this doesn't work by itself when users are in groups
      allow.entity("identity").to(["read", "write", "delete"]),
      allow.groups(["Admins", "Staff", "SystemAdmins"]).to(["read", "write", "delete"]),
    ],
    "media/private/{entity_id}/*": [
      //this fails. Add allow.groups([])... or allow.authenticated() if users are not in groups
      allow.entity("identity").to(["read", "write", "delete"]),
      allow
        .groups(["Admins", "Staff", "SystemAdmins"])
        .to(["read", "write", "delete"]),
    ],
  }),
});```
