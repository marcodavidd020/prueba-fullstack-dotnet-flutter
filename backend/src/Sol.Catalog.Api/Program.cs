WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi();

WebApplication app = builder.Build();

app.MapOpenApi();
app.MapGet("/health", () => Results.Ok(new { status = "ok" }));

app.Run();
