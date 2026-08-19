using System.Threading.RateLimiting;
using Scalar.AspNetCore;
using Serilog;
using Sol.Catalog.Api.Endpoints;
using Sol.Catalog.Api.Middleware;
using Sol.Catalog.Api.Security;
using Sol.Catalog.Application;
using Sol.Catalog.Infrastructure;
using Sol.Catalog.Infrastructure.Persistence;
using ApiKeyOptions = Sol.Catalog.Api.Security.ApiKeyOptions;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

builder.Host.UseSerilog((context, configuration) =>
    configuration.ReadFrom.Configuration(context.Configuration));

builder.Services
    .AddApplication()
    .AddInfrastructure(builder.Configuration);

builder.Services.AddEndpoints();

builder.Services
    .AddOptions<ApiKeyOptions>()
    .BindConfiguration(ApiKeyOptions.SectionName)
    .ValidateOnStart();

builder.Services.AddProblemDetails();
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();

builder.Services.AddOpenApi();

builder.Services.AddHealthChecks()
    .AddDbContextCheck<CatalogDbContext>("base-de-datos");

const string CorsPolicy = "flutter";
string[] allowedOrigins = builder.Configuration
    .GetSection("Cors:AllowedOrigins")
    .Get<string[]>() ?? [];

builder.Services.AddCors(options => options.AddPolicy(CorsPolicy, policy =>
{
    if (allowedOrigins.Length == 0)
    {
        policy.SetIsOriginAllowed(_ => true).AllowAnyHeader().AllowAnyMethod();
    }
    else
    {
        policy.WithOrigins(allowedOrigins).AllowAnyHeader().AllowAnyMethod();
    }

    policy.WithExposedHeaders("ETag");
}));

builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
    options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(context =>
        RateLimitPartition.GetFixedWindowLimiter(
            context.Connection.RemoteIpAddress?.ToString() ?? "desconocido",
            _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 100,
                Window = TimeSpan.FromMinutes(1),
                QueueLimit = 0,
            }));
});

builder.Services.AddScoped<ApiKeyEndpointFilter>();

WebApplication app = builder.Build();

app.UseSerilogRequestLogging();

app.UseExceptionHandler();

app.UseCors(CorsPolicy);

app.UseRateLimiter();

if (app.Environment.IsDevelopment())
{
    await app.Services.InitializeDatabaseAsync();

    app.MapOpenApi();
    app.MapScalarApiReference(options => options
        .WithTitle("Catálogo de productos")
        .WithTheme(ScalarTheme.BluePlanet));
}

app.MapHealthChecks("/health");

app.MapGet("/", () => TypedResults.Ok(new
{
    service = "Sol.Catalog.Api",
    version = "v1",
    docs = "/scalar/v1",
    health = "/health",
}))
.ExcludeFromDescription();

RouteGroupBuilder api = app.MapGroup("/api/v1")
    .AddEndpointFilter<ApiKeyEndpointFilter>()
    .ProducesProblem(StatusCodes.Status401Unauthorized)
    .ProducesProblem(StatusCodes.Status429TooManyRequests);

app.MapEndpoints(api);

await app.RunAsync();

public partial class Program;
