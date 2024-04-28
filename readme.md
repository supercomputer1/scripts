## install
```bash
curl https://raw.githubusercontent.com/supercomputer1/scripts/master/create.sh --output ~/create.sh && chmod +x ~/create.sh   
```

## use 
```bash
~/create.sh "ProjectName"
```

## tree
```bash
.
├── .gitignore
├── Name.sln
├── nuget.config
├── src
│   ├── Name.Application
│   │   ├── Name.Application.csproj
│   │   └── Class1.cs
│   └── Name.Host
│       ├── Name.Host.csproj
│       ├── Program.cs
│       ├── appsettings.development.json
│       └── appsettings.json
└── tests
└── Name.Application.Tests
    ├── Name.Application.Tests.csproj
        ├── GlobalUsings.cs
        └── UnitTest1.cs
```