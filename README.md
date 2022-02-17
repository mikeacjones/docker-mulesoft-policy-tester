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

## Usage

### Build the Image
1. Clone report: `git clone https://github.com/nonamesec/mulesoft-policy-testing-docker`
2. Build Image by executing `docker build -t mule-policy-tester` from repo folder

### Test the policy
1. Ensure that POM.XML has the `groupId` set to `sec.noname`
2. Ensure that POM.XML has the `version` set to `${env.VERSION}`
3. In the policy source code folder, create a file called `policy-config.json`

Example file:
```json
{
  "template" : {
    "groupId" : "sec.noname",
    "assetId" : "noname-security",
    "version" : "2.1.10"
  },
  "api": [
    {
      "id": "1"
    },
    {
      "id": "2"
    }
  ],
  "order": 1,
  "configuration" : {
    "HOST" : "2623-99-104-199-91.ngrok.io",
    "CONNECTIONS": 50,
    "BATCH_SIZE": 10,
    "TIMEOUT": 500,
    "PORT": 443,
    "PATH": "/engine",
    "SOURCE_TYPE": 1,
    "SOURCE_INDEX": 21,
    "DEBUG": true
  }
}
```

4. From the policy folder, execute `docker run -it -v "$(pwd)":/opt/mule/policy-source mule-policy-tester`
5. The mule runtime will start up and automatically apply your policy to the app.
6. Call the app to trigger your policy, `curl http://localhost:8081/app-1`
7. After making changes to the app, simple run the CLI command `update` to redploy and reapply your policy!