# Demonstrating DNS resolution for Fargate ECS task via a private hosted zone in Route 53

# Pre-requisites
- I did everything in WSL, but it ought to work in straight Windows.
- ECR Credential helper to help with pushing to a private ECR respository. This enables the use of
  ./docker-config/config.json to transparently push to ECR when doing a docker push.
  ```json
  {
	"credsStore": "ecr-login"
  }
  ```
- A set of credentials for work in an AWS account (I used IAM Identity Center credentials). These credentials must be
  able to do things like "ECR repository create" and "VPC Creete" and "ECS Cluster Create". I used a one-off AWS account
  I created just for this and I authenticated with AdministratorAccess credentials.
- Be authenticated already with those credentials
- Deploy everything (the ECS cluster, VPC, etc.)
  ```powershell
  cd ./terraform
  terraform apply
  ```
- Build and push the Docker image
  ```
  . ./scripts/New-DockerImageBuildAndPush.ps1
  New-DockerImageBuildAndPush
  ```

# Behavior

## Not resolving.

The code contains an attempt to resolve a made up `host.fictitious-domain-name.com` DNS host name that does not exist
```csharp
static void Main(string[] args)
{
    try {
      string hostName = "host.fictitious-domain-name.com";

      var result = Dns.GetHostEntry(hostName);
      Console.WriteLine($"GetHostEntry({hostName}) returned:");

      foreach (IPAddress address in result.AddressList)
      {
          Console.WriteLine($"  {address}");
      }
    } catch (Exception e) {
      Console.WriteLine($"Got exception: {e.Message}");
    }
    Console.WriteLine($"Done");
}
```

At first, you will find an exception from the catch handler in Cloud Watch log group /aws/ecs/ecs-container-service/ecs-container, log stream ecs/ecs-container
```
Got exception: Name or service not known
Done
```

## Making it resolve

- Create a private hosted zone in the same account in AWS in Route 53. I did this in the console.
- Add an A (alias) record for host.fictitious-domain-name.com and point it to a silly IP address. I used 192.168.1.1,
  which would not work (there is no route to this or anything--it is a typical home retail router ip).
- Watch Cloud Watch. It will take some time. The ECS task is alway exiting when done. The ECS service is retarting it. Next
  time the task starts, you will no longer get an exception, but
  ```
  GetHostEntry(host.fictitious-domain-name.com) returned:
  192.168.1.1
  Done
  ```

# Conclusion

If you create a private zone with en entry for the DNS you want to resolve, this WILL work.  

# Future ideas

Using a Route 53 resolver rule should allow you to get to our company's internal DNS so you don't have to carry an entry in the
private zone. (This would have been harder for me to simulate--I did this all in a personal AWS account). But the
private zone will allow us to move forward for the time being. Please, let's get unstuck.
  




