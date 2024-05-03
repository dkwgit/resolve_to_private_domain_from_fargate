using System.Net;

namespace ecs_container;

class Program
{
    static void Main(string[] args)
    {
        try {
          string hostName = "host.fictitious-domain-name.com";

          var result = Dns.GetHostEntry(hostName);
          Console.WriteLine($"GetHostEntry({hostName}) returns:");

          foreach (IPAddress address in result.AddressList)
          {
              Console.WriteLine($"  {address}");
          }
        } catch (Exception e) {
          Console.WriteLine($"Got exception Exception: {e.Message}");
        }
        Console.WriteLine($"Done");
    }
}
