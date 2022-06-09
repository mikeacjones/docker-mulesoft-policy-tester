# MuleSoft Policy Testing Container

This container is designed to faciliate the local testing of custom MuleSoft policies.

![Preview GIF](./.images/preview.gif)

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
1. Clone this repository
2. Build Image by executing `docker build -t mule-policy-tester .` from repo folder

### Test the policy
1. Ensure that POM.XML has the `groupId` set to match your `policy-config.json`. Example: `sec.noname`
2. Ensure that POM.XML has the `version` set to `${VERSION}`
3. In the policy source code folder, create a file called `policy-config.json`. This file contains the configuration for your application. By default, there is one included application with an autodiscovery ID of 1. Set up your `policy-config.json` to include which applications you want your policy applied to. If you would like to use your own applications/domains, mount `/opt/mule/apps` and `/opt/mule/domains`.

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

4. From the policy folder, execute `docker run --rm -p 8081:8081 -it -v "$(pwd)":/opt/mule/policy-source mule-policy-tester`. With this command, we are mounting the source code to `/opt/mule/policy-source`. You must mount your code here or your policy will not be applied. The `--rm` ensures our docker image cleans itself up when we exit. The `-p 8081:8081` allows you to call the test APIs from your local machine, allowing use of tools like Postman and Insomnia.
5. The mule runtime will start up and automatically apply your policy to the app.
6. Call the app to trigger your policy, `curl http://localhost:8081/app-1`
7. After making changes to the app, simple run the CLI command `update` to redploy and reapply your policy!
8. If adding new config fields, simply repeat the step above after updating the policy-config.json! `update`

### Viewing app logs:

`tail -f ${MULE_HOME}/logs/app-1-hello-world.log`
