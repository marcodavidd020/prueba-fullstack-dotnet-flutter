using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Sol.Catalog.Application.Abstractions.Persistence;
using Sol.Catalog.Infrastructure.Persistence;
using Sol.Catalog.Infrastructure.Persistence.Repositories;
using Sol.Catalog.Infrastructure.Persistence.Seed;

namespace Sol.Catalog.Infrastructure;

public static class DependencyInjection
{
    public const string ConnectionStringName = "Catalog";

    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(services);
        ArgumentNullException.ThrowIfNull(configuration);

        string connectionString = configuration.GetConnectionString(ConnectionStringName)
            ?? "Data Source=catalog.db";

        services.AddDbContext<CatalogDbContext>(options => options.UseSqlite(connectionString));

        services.AddScoped<ProductRepository>();
        services.AddScoped<IProductReader>(sp => sp.GetRequiredService<ProductRepository>());
        services.AddScoped<IProductWriter>(sp => sp.GetRequiredService<ProductRepository>());
        services.AddScoped<IUnitOfWork>(sp => sp.GetRequiredService<CatalogDbContext>());

        return services;
    }

    public static async Task InitializeDatabaseAsync(
        this IServiceProvider services,
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(services);

        using IServiceScope scope = services.CreateScope();

        CatalogDbContext db = scope.ServiceProvider.GetRequiredService<CatalogDbContext>();
        TimeProvider clock = scope.ServiceProvider.GetRequiredService<TimeProvider>();

        await db.Database.MigrateAsync(cancellationToken).ConfigureAwait(false);
        await CatalogSeeder.SeedAsync(db, clock, cancellationToken).ConfigureAwait(false);
    }
}
