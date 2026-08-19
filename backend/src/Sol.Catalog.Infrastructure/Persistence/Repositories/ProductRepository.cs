using Microsoft.EntityFrameworkCore;
using Sol.Catalog.Application.Abstractions.Persistence;
using Sol.Catalog.Application.Common;
using Sol.Catalog.Domain.Products;
using Sol.Catalog.Infrastructure.Persistence.Configurations;

namespace Sol.Catalog.Infrastructure.Persistence.Repositories;

internal sealed class ProductRepository(CatalogDbContext db) : IProductReader, IProductWriter
{
    public async Task<PagedResult<Product>> SearchAsync(
        ProductQuerySpec spec,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(spec);

        IQueryable<Product> query = db.Products.AsNoTracking();

        query = ApplyFilters(query, spec);

        int total = await query.CountAsync(cancellationToken).ConfigureAwait(false);

        if (total == 0)
        {
            return PagedResult.Empty<Product>(spec.Page, spec.PageSize);
        }

        List<Product> items = await ApplySort(query, spec)
            .Skip((spec.Page - 1) * spec.PageSize)
            .Take(spec.PageSize)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return new PagedResult<Product>(items, spec.Page, spec.PageSize, total);
    }

    public async Task<Product?> GetByIdAsync(int id, CancellationToken cancellationToken) =>
        await db.Products
            .FirstOrDefaultAsync(p => p.Id == id, cancellationToken)
            .ConfigureAwait(false);

    public void Update(Product product)
    {
        ArgumentNullException.ThrowIfNull(product);
        db.Products.Update(product);
    }

    private static IQueryable<Product> ApplyFilters(IQueryable<Product> query, ProductQuerySpec spec)
    {
        if (!string.IsNullOrWhiteSpace(spec.SearchTerm))
        {
            string pattern = $"%{SearchNormalizer.NormalizeForLike(spec.SearchTerm)}%";

            query = query.Where(p => EF.Functions.Like(
                EF.Property<string>(p, ProductConfiguration.SearchTextProperty),
                pattern,
                SearchNormalizer.LikeEscape.ToString()));
        }

        if (spec.MinPrice is { } min)
        {
            query = query.Where(p => p.Price.Amount >= min);
        }

        if (spec.MaxPrice is { } max)
        {
            query = query.Where(p => p.Price.Amount <= max);
        }

        if (!string.IsNullOrWhiteSpace(spec.Currency))
        {
            query = query.Where(p => p.Price.Currency == spec.Currency);
        }

        if (spec.OnlyInStock)
        {
            query = query.Where(p => p.Stock > 0);
        }

        return query;
    }

    private static IOrderedQueryable<Product> ApplySort(IQueryable<Product> query, ProductQuerySpec spec)
    {
        bool asc = spec.SortDirection == SortDirection.Asc;

        return spec.SortBy switch
        {
            ProductSortField.Price => asc
                ? query.OrderBy(p => p.Price.Amount).ThenBy(p => p.Id)
                : query.OrderByDescending(p => p.Price.Amount).ThenBy(p => p.Id),

            ProductSortField.Stock => asc
                ? query.OrderBy(p => p.Stock).ThenBy(p => p.Id)
                : query.OrderByDescending(p => p.Stock).ThenBy(p => p.Id),

            ProductSortField.Sku => asc
                ? query.OrderBy(p => p.Sku.Value).ThenBy(p => p.Id)
                : query.OrderByDescending(p => p.Sku.Value).ThenBy(p => p.Id),

            _ => asc
                ? query.OrderBy(p => p.Name).ThenBy(p => p.Id)
                : query.OrderByDescending(p => p.Name).ThenBy(p => p.Id),
        };
    }
}
