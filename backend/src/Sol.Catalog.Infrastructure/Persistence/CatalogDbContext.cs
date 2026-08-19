using System.Reflection;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Sol.Catalog.Application.Abstractions.Persistence;
using Sol.Catalog.Domain.Common;
using Sol.Catalog.Domain.Products;
using Sol.Catalog.Infrastructure.Persistence.Configurations;

namespace Sol.Catalog.Infrastructure.Persistence;

public sealed class CatalogDbContext(DbContextOptions<CatalogDbContext> options)
    : DbContext(options), IUnitOfWork
{
    public DbSet<Product> Products => Set<Product>();

    async Task<Result> IUnitOfWork.SaveChangesAsync(CancellationToken cancellationToken)
    {
        try
        {
            await SaveChangesAsync(cancellationToken).ConfigureAwait(false);
            return Result.Success();
        }
        catch (DbUpdateConcurrencyException)
        {
            return Result.Failure(ProductErrors.ConcurrencyConflict);
        }
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        UpdateSearchText();
        return base.SaveChangesAsync(cancellationToken);
    }

    public override int SaveChanges()
    {
        UpdateSearchText();
        return base.SaveChanges();
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        ArgumentNullException.ThrowIfNull(modelBuilder);

        modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());

        base.OnModelCreating(modelBuilder);
    }

    private void UpdateSearchText()
    {
        foreach (EntityEntry<Product> entry in ChangeTracker.Entries<Product>())
        {
            if (entry.State is not (EntityState.Added or EntityState.Modified))
            {
                continue;
            }

            entry.Property<string>(ProductConfiguration.SearchTextProperty).CurrentValue =
                SearchNormalizer.Normalize($"{entry.Entity.Name} {entry.Entity.Sku.Value}");
        }
    }
}
