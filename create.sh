#!/bin/bash

NAME=${1:?"missing arg position 1 for PROJECT_NAME"}
HOST=$1.Host
APPLICATION=$1.Application
TEST=$1.Application.Tests

if [ -d "$NAME" ]; then
  echo "Directory $NAME already exists."
  echo "Exiting.."
  exit 1
fi

mkdir $NAME 
cd $NAME 
mkdir src 
mkdir tests

# nuget 
touch nuget.config
/bin/cat > nuget.config <<EOM 
<?xml version="1.0" encoding="utf-8"?>
<configuration>
    <packageSources>
        <add key="nuget.org" value="https://api.nuget.org/v3/index.json" protocolVersion="3" />
    </packageSources>
</configuration>
EOM

# dotnet stuff
dotnet new gitignore

dotnet new console -n $HOST -o src/$HOST
dotnet new classlib -n $APPLICATION -o src/$APPLICATION
dotnet new xunit -n $TEST -o tests/$TEST

dotnet new sln -n $NAME
dotnet sln add src/*/*.csproj
dotnet sln add tests/*/*.csproj

cd src/$HOST
dotnet add reference ../$APPLICATION/$APPLICATION.csproj
dotnet add package Microsoft.Extensions.Hosting --interactive
dotnet add package Serilog.AspNetCore --interactive
cd ../../

cd tests/$TEST
dotnet add reference ../../src/*/*.csproj
cd ../../

cd src/$APPLICATION
mkdir Core 
mkdir Infrastructure
cd ../../

# file 
touch src/$HOST/appsettings.json
touch src/$HOST/appsettings.development.json

# program.cs template
/bin/cat > src/$HOST/Program.cs <<EOM 
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
EOM

# .gitignore append
/bin/cat >> .gitignore <<EOM 

# Appsettings
appsettings.json 
appsettings.*.json

# Rider
.idea/

# MacOS
.DS_Store
EOM

# appsettings.json template 
/bin/cat >> src/$HOST/appsettings.json <<EOM
{
    "Serilog": {
        "Using": [
            "Serilog.Sinks.Console",
            "Serilog.Sinks.File"
        ],
        "MinimumLevel": {
            "Default": "Debug",
            "Override": {
                "Azure.Messaging.ServiceBus": "Warning",
                "Microsoft.EntityFrameworkCore": "Warning"
            }
        },
        "WriteTo": [
            {
                "Name": "Console",
                "Args": {
                    "theme": "Serilog.Sinks.SystemConsole.Themes.AnsiConsoleTheme::Code, Serilog.Sinks.Console",
                    "restrictedToMinimumLevel": "Debug"
                }
            },
            {
                "Name": "File",
                "Args": {
                    "path": "log-.log",
                    "rollingInterval": "Day",
                    "restrictedToMinimumLevel": "Debug"
                }
            }
        ]
    }
}
EOM

# appsettings.development.json template 
/bin/cat >> src/$HOST/appsettings.development.json <<EOM
{
    "Serilog": {
        "Using": [
            "Serilog.Sinks.Console"
        ],
        "MinimumLevel": {
            "Default": "Debug",
            "Override": {
                "Azure.Messaging.ServiceBus": "Warning",
                "Microsoft.EntityFrameworkCore": "Warning"
            }
        },
        "WriteTo": [
            {
                "Name": "Console",
                "Args": {
                    "theme": "Serilog.Sinks.SystemConsole.Themes.AnsiConsoleTheme::Code, Serilog.Sinks.Console",
                    "restrictedToMinimumLevel": "Debug"
                }
            }
        ]
    }
}
EOM

grep -v "</Project>" src/$HOST/$HOST.csproj > temp && mv temp src/$HOST/$HOST.csproj
/bin/cat >> src/$HOST/$HOST.csproj <<EOM
  <ItemGroup>
    <None Update="appsettings.json">
      <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
      <CopyToPublishDirectory>Never</CopyToPublishDirectory>
    </None>
  </ItemGroup>

  <ItemGroup>
    <None Update="appsettings.*.json">
      <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
      <CopyToPublishDirectory>Never</CopyToPublishDirectory>
    </None>
  </ItemGroup>

</Project>
EOM
