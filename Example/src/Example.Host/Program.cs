using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Serilog;

using var host = Host.CreateDefaultBuilder(args)
    .ConfigureAppConfiguration(config =>
    {
        config.SetBasePath(Directory.GetCurrentDirectory());
        config.AddJsonFile("appsettings.json", optional: false);
        config.AddJsonFile("appsettings.development.json", optional: true);
        config.AddCommandLine(args);
    })
    .ConfigureServices((hostContext, services) =>
    {
                                                           
    })
   .UseSerilog((hostContext, provider, loggerConfiguration) =>
   {
       loggerConfiguration
           .ReadFrom.Configuration(hostContext.Configuration)
           .ReadFrom.Services(provider)
           .Enrich.FromLogContext();
   })
   .Build();

await host.RunAsync();
