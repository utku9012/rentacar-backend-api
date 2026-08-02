using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.EntityFrameworkCore;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;
using Prometheus;
using RentACarApi.Data;
using RentACarApi.HealthChecks;
using RentACarApi.Repositories;
using RentACarApi.Services;
using Serilog;

if (args is ["--healthcheck", var healthcheckUrl])
{
    using var httpClient = new HttpClient
    {
        Timeout = TimeSpan.FromSeconds(3)
    };

    try
    {
        var response = await httpClient.GetAsync(healthcheckUrl);
        Environment.Exit(response.IsSuccessStatusCode ? 0 : 1);
    }
    catch
    {
        Environment.Exit(1);
    }
}

var builder = WebApplication.CreateBuilder(args);

builder.Host.UseSerilog((context, configuration) =>
    configuration
        .ReadFrom.Configuration(context.Configuration)
        .Enrich.FromLogContext()
        .WriteTo.Console());

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

if (builder.Configuration.GetValue<bool>("Observability:Tracing:Enabled"))
{
    var serviceName = builder.Configuration["Observability:ServiceName"]
        ?? builder.Configuration["Application:Name"]
        ?? "RentACarApi";
    var serviceVersion = builder.Configuration["Observability:ServiceVersion"]
        ?? builder.Configuration["IMAGE_TAG"]
        ?? "local";
    var otlpEndpoint = builder.Configuration["Observability:OtlpEndpoint"]
        ?? builder.Configuration["OTEL_EXPORTER_OTLP_ENDPOINT"];

    builder.Services.AddOpenTelemetry()
        .ConfigureResource(resource => resource
            .AddService(serviceName: serviceName, serviceVersion: serviceVersion)
            .AddAttributes(new Dictionary<string, object>
            {
                ["deployment.environment"] = builder.Environment.EnvironmentName
            }))
        .WithTracing(tracing =>
        {
            tracing
                .AddAspNetCoreInstrumentation()
                .AddHttpClientInstrumentation();

            if (!string.IsNullOrWhiteSpace(otlpEndpoint))
            {
                tracing.AddOtlpExporter(options =>
                    options.Endpoint = new Uri(otlpEndpoint));
            }
        });
}

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddHealthChecks()
    .AddCheck("live", () => Microsoft.Extensions.Diagnostics.HealthChecks.HealthCheckResult.Healthy(), tags: new[] { "live" })
    .AddCheck<DatabaseHealthCheck>("postgresql", tags: new[] { "ready" });

builder.Services.AddScoped<IVehicleRepository, VehicleRepository>();
builder.Services.AddScoped<IRentalRepository, RentalRepository>();
builder.Services.AddScoped<IRentalService, RentalService>();

var app = builder.Build();

if (args.Contains("--migrate"))
{
    using var migrationScope = app.Services.CreateScope();
    var migrationDbContext = migrationScope.ServiceProvider.GetRequiredService<AppDbContext>();
    migrationDbContext.Database.Migrate();
    return;
}

if (app.Environment.IsDevelopment() || app.Environment.IsEnvironment("Docker"))
{
    app.UseSwagger();
    app.UseSwaggerUI();
    app.MapGet("/", () => Results.Redirect("/swagger"));
}

if (!app.Environment.IsEnvironment("Docker") && !app.Environment.IsEnvironment("Testing"))
{
    app.UseHttpsRedirection();
}

app.UseHttpMetrics();
app.MapControllers();
app.MapMetrics();
app.MapHealthChecks("/health/live", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("live")
});
app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready")
});

app.Run();

public partial class Program
{
}
