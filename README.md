# MuleSoft Policy Testing Container

This container is designed to faciliate the local testing of custom MuleSoft policies.

By default, the container starts up with the following apps:

## Hello World

This app returns the following JSON to any CRUD method:

```json
{
  "message": "Hello world"
}
```

The endpiont is: `/app-1`